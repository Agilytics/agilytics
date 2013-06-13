class Grid
  attr_reader :model_grid

  def jira
    unless @jira
      @jira = JiraCaller.new
    end
    @jira
  end

  def save
    @model_grid.each do |board|
      board.save()
    end
  end

  def update
    @grid = jira.getBoards
    updateModelGrid
    createSprints
    getSprintChanges
    processAllChanges
  end

  def create
    @grid = jira.getBoards
    createModelGrid
    createSprints
    getSprintChanges
    processAllChanges
  end

  def updateModelGrid
    @model_grid.where(jid: key).first
    @grid.each{ | json_board|
      unless @model_grid.where(jid: key).exists?
        @model_grid << Board.new( jId(json_board) )
      end
    }
  end

  def createModelGrid
    @model_grid = Array.new unless @model_grid
    @grid.each { |json_board|
       @model_grid << Board.new( jId(json_board) )
    }
  end

  def createSprints
    @model_grid.each { |board|
      sprints = jira.getSprints(board.jid.to_s)
      sprints['sprints'].each{ |s|
        addOrCreateSprint(board, s)
      }
    }
  end

  def addOrCreateSprint board, sprint

    found = false
    board.sprints.each{|s|
      if s.jid == sprint['id']
        s.update(sprint)
        found = true
      end
    }

    unless found
      board.sprints << Sprint.new( jId(sprint) )
    end

  end

  def getSprintChanges
    @model_grid.each do |board|
      board.sprints.each do |sprint|
        unless sprint.have_all_changes
          change_set = jira.getSprintChanges board.jid, sprint.jid
          sprint.change_set = ChangeSet.new change_set

          if sprint.closed
            sprint.have_all_changes = true
          end
        end
      end
    end
  end

  def jId o
    o[:jid] = o['id']
    o['id'] = nil
    o
  end

  def processAllChanges
    @model_grid.each{|board|
      board.sprints.each{ |sprint|
        unless sprint.have_processed_all_changes
          processChanges sprint
          getStoryDetailsForSprint sprint
          sprint.have_processed_all_changes = true
        end
      }
    }
  end

  def processChanges(sprint)
    ch = sprint.change_set[:changes]
    ch.keys.each do |timestamp|
      ch[timestamp].each do |o1|

        curStory = getOrCreateStoryOnSprint(sprint, o1['key'], timestamp)
        setSizeOfStory(curStory, o1)
        setIsStoryDone(curStory, o1)
        setIfAddedOrRemoved(curStory, o1, timestamp, sprint)

      end
    end
  end

  def getOrCreateStoryOnSprint(sprint, key, timestamp)
    if sprint.stories.where(jid: key).exists?
      curStory = sprint.stories.where(jid: key).first
    else
      curStory = Story.new unless sprint.stories.where(jid: key).exists?
      curStory[:jid] = key
      curStory.init_date = Time.at Integer(timestamp)
      sprint.stories << curStory
    end
    curStory
  end

  def setAssignee(issue, story)
    assignee = issue['fields']['assignee']
    if assignee
      story.assignee = JiraUser.new unless story.assignee
      populateUser story.assignee, assignee
    else
      story.assignee = nil
    end
  end

  def setReporter(issue, story)
    reporter = issue['fields']['reporter']
    if reporter
      story.reporter = JiraUser.new unless story.reporter
      populateUser story.reporter, reporter
    else
      story.assignee = nil
    end
  end

  def populateUser user, obj
    user.name = obj['name']
    user.email_address = obj['emailAddress']
    user.display_name =  obj['displayName']
  end

  def getStoryDetailsForSprint(sprint)
    sprint.stories.each do |story|
      unless issue.assignee && issue.reporter
        issue = jira.getStoryDetail story.jid
        setAssignee issue, story
        setReporter issue, story
      end
    end
  end

  def setSizeOfStory(curStory, o1)

    if o1['statC'] && o1['statC']['newValue']
      curStory.size = o1['statC']['newValue']
    end

    if o1['statC'] && ( o1['statC']['newValue'] || o1['statC']['noStatsValue'] )
      unless curStory.is_initialized
        if o1['statC']['noStatsValue']
          curStory.init_size = 0
          curStory.size = 0
        else
          curStory.init_size = o1['statC']['newValue'] || curStory.size
        end
        curStory.is_initialized = true
      end
    end

  end

  def setIsStoryDone(curStory, o1)

    if o1['column']
      curStory.done = !o1['column']['notDone']
    end

  end

  def setIfAddedOrRemoved(curStory, o1, timestamp, sprint)

    if o1['added']

      storyAddedDate = Time.at Integer(timestamp)
      curStory.init_date = storyAddedDate
      startTime = Time.at sprint.change_set.startTime
      curStory.was_added = storyAddedDate > startTime
      curStory.was_removed = false
    end

    if o1['added'] == false
      curStory.was_removed = true
    end

  end

end
