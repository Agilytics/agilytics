  class AgileData

  def initialize(dataProvider)
    @dataProvider = dataProvider
  end

  def save
    @model_grid.each do |board|
      board.save()
    end
  end

  def update
    @boards = @dataProvider.getBoards
    updateModelGrid
    createSprints
    getSprintChanges
    processAllChanges
  end

  def create

    @boards = @dataProvider.getBoards
    @sprintChanges = @dataProvider.sprintChangesFor(@boards)


    ################
    #createModelGrid
    #createSprints
    #getSprintChanges
    #processAllChanges
  end

  protected

    def updateModelGrid
      @model_grid.where(jid: key).first
      @grid.each{ | json_board |
        unless @model_grid.where(pid: key).exists?
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
        story.assignee = AgileUser.new unless story.assignee
        populateUser story.assignee, assignee
      else
        story.assignee = nil
      end
    end

    def setReporter(issue, story)
      reporter = issue['fields']['reporter']
      if reporter
        story.reporter = AgileUser.new unless story.reporter
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
          issue = @dataProvider.getStoryDetail story.jid
          setAssignee issue, story
          setReporter issue, story
        end
      end
    end

end
