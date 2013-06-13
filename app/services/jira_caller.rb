class JiraCaller

  include HTTParty
  #basic_auth @uid, @pwd
  #base_uri @site

  def initialize(uid, pwd, site)
    @site = site
    @auth = {:username => uid, :password => pwd}
  end

  def httpGet(uri)
    options = {}
    options.merge!({:basic_auth => @auth})
    self.class.get(uri, options)
  end

  def getSprintChanges(boardId, sprint)

    response = httpGet("#{@site}/rest/greenhopper/1.0/rapid/charts/scopechangeburndownchart.json?rapidViewId=#{boardId}&sprintId=#{sprint.pid}")

    case response.code
    when 200
      response
    when 404
      []
    else
      []
    end
  end

  def getStoryDetail(storyId)

    response = httpGet("#{@site}/rest/api/2/issue/#{storyId}")

    case response.code
    when 200
      response
    when 404
      Object.new
    else
      object.new
    end
  end

  def getSprints(boardId)
    response = httpGet("#{@site}/rest/greenhopper/1.0/sprints/#{boardId}")

    case response.code
      when 200
        response
      when 404
        []
      else
        []
      end
  end

  def getBoards
    response = httpGet("#{@site}/rest/greenhopper/1.0/rapidviews/list.json")
    case response.code
      when 200
        boards = mapBoards response['views']
        addSprints boards
      when 404
        []
      else
        []
      end
  end

  def sprintChangesFor(boards)

      changes = Array.new()

      boards.each do |board|
        board.sprints.each do |sprint|
          unless sprint.have_all_changes

            change_set = getSprintChanges(board.pid, sprint)

            change_set['changes'].keys.each do |time|
              val = change_set['changes'][time]

              sprint.end_date = Time.at(change_set['endTime'])
              sprint.start_date = Time.at(change_set['startTime'])

              val.each do | change |

                change = makeChange(time, change, board, sprint)

                changes << change

                story = getOrCreateStory(change.associated_story_pid, change)

                if change.associated_subtask_pid
                  getOrCreateSubtask(story, change.associated_subtask_pid)
                else
                  board.stories << story
                  sprint_story = getOrCreateSprintStory(sprint, story, time)
                  setSizeOfStory(sprint_story, change)
                  setIsStoryDone(sprint_story, change)
                  setIfAddedOrRemoved(sprint_story, change, time, sprint)
                end

                change.associated_story_pid = story.pid

              end
            end

            if sprint.closed
              sprint.have_all_changes = true
            end

            board.save()

          end
        end
      end

      changes
    end

  protected

  def setIfAddedOrRemoved(sprint_story, change, time, sprint)
      sprint_story.was_added = change.action == Change::ADDED
      sprint_story.was_removed = change.action == Change::REMOVED
  end

  def setIsStoryDone(sprint_story, change)
      if change.action == Change::STATUS_LOCATION_CHANGE
        # assumption being that the events are happening in order of time, last status is current
        sprint_story.is_done = change.is_done
      end
  end

  def setSizeOfStory(sprintStory, change)
    if change.action == Change::ESTIMATE_CHANGED
      sprintStory.size += change.new_value.to_i
      unless sprintStory.is_initialized
        sprintStory.init_size = change.new_value.to_i
        sprintStory.is_initialized = true
      end
    end

  end

  def getOrCreateSprintStory(sprint, story, time)
    if sprint.sprint_stories.where(pid: key).exists?
      sprintStory = sprint.sprint_stories.where(pid: story.pid).first
    else
      sprintStory = SprintStory.new
      sprintStory.pid = story.pid
      sprintStory.init_date = time.to_date()
      sprint.sprint_stories << sprintStory
    end
    sprintStory
  end

  def getOrCreateSubtask(story, subtask_pid)

    st = Subtask.find_by_pid(subtask_pid)
    unless st
      st = Subtask.new()
      story.subtasks << st
    end

    st.assignee = getOrCreateUser(fields['reporter'])
    st.reporter = getOrCreateUser(fields['assignee'])
    st.name = fields['name']
    st.type = Story::STORY
    st.description = fields['description']
    st.acuity = fields['priority']['name']
    st.done = fields['status']['name'] == 'Closed'
    st.created_date = Time.at(Integer(fields['created']))

    st

  end

  def getOrCreateStory(story_pid, change)

      # it's active record so just
#      c = Card.find_by_pid(story_pid)
      c = nil
      unless c
        c = Story.new()
        s = getStoryDetail(story_pid)

        fields = s['fields']

        c.assignee = getOrCreateUser(fields['reporter'])
        c.reporter = getOrCreateUser(fields['assignee'])
        c.name = fields['summary']
        c.card_type = Story::STORY
        c.description = fields['description']

        if(fields['priority'])
          c.acuity = fields['priority']['name']
        end

        if(fields['status'])
          c.done = fields['status']['name'] == 'Closed'
        end

        c.create_date = fields['created'].to_date()

      end

      c.pid = story_pid

      c
  end

  def getOrCreateUser(user_blob)

    unless user_blob
      return nil
    end

    user = AgileUser.find_by_pid(user_blob['name'])
    unless user
      user = AgileUser.new()
      user.pid = user_blob['name']
    end
    user.display_name = user_blob['displayName']
    user.email_address = user_blob['emailAddress']
    user.name = user_blob['name']
    user.pid = user.name

    user
  end

  def mapBoards (jira_boards)
    boards = Array.new()
    jira_boards.each do |jb|
      b = Board.find_by_pid(jb['id'])

      if(!b)
        b = Board.new()
      end

      b.pid = jb['id'].to_s()
      b.name = jb['name']
      b.is_sprint_board = jb['sprintSupportEnabled']

      boards << b
    end
    boards
  end

  def addSprints(boards)
    boards.each { |board|
      sprints = getSprints(board.pid)
      sprints['sprints'].each{ |s|
        addOrCreateSprint(board, s)
      }
    }
  end

  def addOrCreateSprint( board, sprint )
    s = nil
    board.sprints.each { |ls|
      if ls.pid == sprint['id'].to_s()
        s = ls
      end
    }

    unless s
      s = Sprint.new()
      s.pid = sprint['id'].to_s()
      board.sprints << s
    end

    s.name = sprint['name']
    s.closed = sprint['closed']

  end


  def makeChange(timestamp, change, board, sprint)

        issueId = change['key']
        thisParentStoryId = change['issueToParentKeys'][issueId] if change['issueToParentKeys']

        new_change = Change.new()

        if thisParentStoryId then
          new_change.associated_story_pid = thisParentStoryId
          new_change.associated_subtask_pid = issueId
        else
          new_change.associated_story_pid = issueId
        end

        new_change.time = Time.at(Integer(timestamp))
        new_change.board = board
        new_change.board_pid = board.pid
        new_change.sprint = sprint
        new_change.sprint_pid = sprint.pid

        determineTypeAndApply(new_change, change)

        new_change
  end

  def determineTypeAndApply(new_change, change)

      if_SizeType_Set(new_change, change)
      if_Done_Set(new_change, change)
      if_AddedRemoved_Set(new_change, change)

  end

  def if_SizeType_Set(new_change, change)

      if change['statC']

        new_change.action = Change::ESTIMATE_CHANGED
        if change['statC']['noStatsValue']
            new_change.new_value = change['statC']['newValue'] = 0
        end
        if change['statC']['newValue']
          new_change.new_value = change['statC']['newValue']
        end

      end

  end

  def if_Done_Set(new_change, change)
      if change['column']
        new_change.action = Change::STATUS_LOCATION_CHANGE
        new_change.is_done = !change['column']['notDone']
        new_change.location = change['column']['newStatus']
      end
  end

  def if_AddedRemoved_Set(new_change, change)
      if change['added'] == true
        new_change.action = Change::ADDED

      end
      if change['added'] == false
        new_change.action = Change::REMOVED
      end
  end

end