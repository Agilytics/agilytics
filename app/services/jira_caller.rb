class JiraCaller

  def initialize(rest_caller, site)
    @site = site
    @rest_caller = rest_caller
  end

  def http_get(uri)
    @rest_caller.http_get(uri)
  end

  def get_sprint_changes(boardId, sprint)
    response = http_get("#{@site}/rest/greenhopper/1.0/rapid/charts/scopechangeburndownchart.json?rapidViewId=#{boardId}&sprintId=#{sprint.pid}")

    case response.code
      when 200
        response
      when 404
        []
      else
        []
      end
  end

  def get_story_detail(storyId)
    response = http_get("#{@site}/rest/api/2/issue/#{storyId}")

    case response.code
      when 200
        response
      when 404
        Object.new
      else
        Object.new
      end
    end

  def get_sprints(boardId)
    response = http_get("#{@site}/rest/greenhopper/1.0/sprints/#{boardId}")

    case response.code
      when 200
        response
      when 404
        []
      else
        []
      end
  end

  def get_boards
    response = http_get("#{@site}/rest/greenhopper/1.0/rapidviews/list.json")
    case response.code
      when 200
        boards = map_boards response['views']
        add_sprints boards
      when 404
        []
      else
        []
      end
  end

  def sprint_changes_for(boards)

      changes = Array.new()
      boards.each do |board|
###############################################################
          if(board.pid == '17')
###############################################################
            board.sprints.each do |sprint|
              process_sprint(board, changes, sprint)
            end
          end
      end

  end

  def process_sprint(board, changes, sprint)
    unless sprint.have_all_changes
      stories = Hash.new
      subtasks = Hash.new
      @assignees = Hash.new
      @reporters = Hash.new

      change_set = get_sprint_changes(board.pid, sprint)

      change_set['changes'].keys.each do |time|

        val = change_set['changes'][time]

        sprint.end_date = Time.at(change_set['endTime'])
        sprint.start_date = Time.at(change_set['startTime'])

        val.each do |change|

          process_change(board, change, changes, sprint, stories, subtasks, time)

        end

      end

      if sprint.closed
        sprint.have_all_changes = true
      end

      sprint.save()

    end

    board.save()
  end

  def process_change(board, change, changes, sprint, stories, subtasks, time)
    change = make_change(time, change, board, sprint)
    changes << change

    story_pid = change.associated_story_pid

    if stories.key?(story_pid)
      story = stories[story_pid]
    elsif subtasks.key?(story_pid)
      story = subtasks[story_pid]
    else
      story = get_or_create_story(change.associated_story_pid, board)
    end

    if change.associated_subtask_pid
      subtasks[story_pid] = story
      get_or_create_subtask(story, change.associated_subtask_pid)

    else
      stories[story_pid] = story
      sprint_story = get_or_create_sprint_story(sprint, story, time)

      sprint_story.pid = story_pid
      sprint_story.assignee = story.assignee
      sprint_story.reporter = story.reporter

      set_size_of_story(sprint_story, change)
      set_is_story_done(sprint_story, change)
      set_if_added_or_removed(sprint_story, change, time, sprint)
      sprint_story.save()

    end
    story.save()

    change.associated_story_pid = story.pid
  end

  protected

  def set_if_added_or_removed(sprint_story, change, time, sprint)
      sprint_story.was_added = change.action == Change::ADDED
      sprint_story.was_removed = change.action == Change::REMOVED
  end

  def set_is_story_done(sprint_story, change)
      if change.action == Change::STATUS_LOCATION_CHANGE
        # assumption being that the events are happening in order of time, last status is current
        sprint_story.is_done = change.is_done
      end
  end

  def set_size_of_story(sprint_story, change)
    if change.action == Change::ESTIMATE_CHANGED
      #binding.pry
      sprint_story.size = 0 unless sprint_story.size
      sprint_story.size += change.new_value.to_i
      unless sprint_story.is_initialized
        sprint_story.init_size = change.new_value.to_i
        sprint_story.is_initialized = true
      end
    end
  end

  def get_or_create_sprint_story(sprint, story, time)
    if sprint.sprint_stories.where(pid: story.pid).exists?
      sprintStory = sprint.sprint_stories.where(pid: story.pid).first
    else
      sprintStory = SprintStory.new
      sprintStory.pid = story.pid
      sprintStory.init_date = Time.at time.to_i
      sprintStory.init_size = 0

      sprint.sprint_stories << sprintStory
      story.sprint_stories << sprintStory
    end
    sprintStory
  end

  def get_or_create_subtask(story, subtask_pid)

    st = Subtask.find_by_pid(subtask_pid)
    unless st
      st = Subtask.new()
      story.subtasks << st
    end

    st.assignee = get_or_create_user(fields['reporter'], Assignee, @assignees)
    st.reporter = get_or_create_user(fields['assignee'], Reporter, @reporters)
    st.name = fields['name']
    st.type = Story::STORY
    st.description = fields['description']
    st.acuity = fields['priority']['name']
    st.done = fields['status']['name'] == 'Closed'
    st.created_date = Time.at(Integer(fields['created']))

    st

  end

  def get_or_create_story(story_pid, board)

      # it's active record so just
      story = Story.find_by_pid(story_pid)
      unless story
        story = Story.new()
        s = get_story_detail(story_pid)

        fields = s['fields']

        story.size = fields['customfield_10004']
        story.reporter = get_or_create_user(fields['reporter'], Reporter, @reporters)
        story.assignee = get_or_create_user(fields['assignee'], Assignee, @assignees)
        story.name = fields['summary']
        story.story_type = Story::STORY
        story.description = fields['description']

        if(fields['priority'])
          story.acuity = fields['priority']['name']
        end

        if(fields['status'])
          story.done = fields['status']['name'] == 'Closed'
        end

        story.create_date = fields['created'].to_date()

        board.stories << story

      end

      story.pid = story_pid

      story
  end

  def get_or_create_user(user_blob, userClass, collectionOfUserType)

    unless user_blob
      return nil
    end

    # remove spaces
    user_name = user_blob['name'].gsub!(/\s/,'+')

    user = collectionOfUserType[user_name]
    user = userClass.find_by_pid(user_name) unless user
    unless user
      user = userClass.new()
      user.pid = user_name
      collectionOfUserType[user_name] = user
    end
    user.display_name = user_blob['displayName']
    user.email_address = user_blob['emailAddress']
    user.name = user_blob['name']
    user.pid = user.name

    user.save()

    user
  end

  def map_boards (jira_boards)
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

  def add_sprints(boards)
    boards.each { |board|
      sprints = get_sprints(board.pid)
      sprints['sprints'].each{ |s|
        add_or_create_sprint(board, s)
      }
    }
  end

  def add_or_create_sprint( board, sprint )
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


  def make_change(timestamp, change, board, sprint)

        issueId = change['key']
        thisParentStoryId = change['issueToParentKeys'][issueId] if change['issueToParentKeys']

        new_change = Change.new()
        new_change.pid = "#{timestamp.to_s}_#{board.pid}_#{sprint.pid}"

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

        determine_type_and_apply(new_change, change)

        new_change.save()

        new_change
  end

  def determine_type_and_apply(new_change, change)

      if_size_type_set(new_change, change)
      if_done_set(new_change, change)
      if_added_removed_set(new_change, change)

  end

  def if_size_type_set(new_change, change)

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

  def if_done_set(new_change, change)
      if change['column']
        new_change.action = Change::STATUS_LOCATION_CHANGE
        new_change.is_done = !change['column']['notDone']
        new_change.location = change['column']['newStatus']
      end
  end

  def if_added_removed_set(new_change, change)
      if change['added'] == true
        new_change.action = Change::ADDED

      end
      if change['added'] == false
        new_change.action = Change::REMOVED
      end
  end

end