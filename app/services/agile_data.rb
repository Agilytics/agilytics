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

  def produceCube

      # cube
      @cube = {}
      @cube['boards'] = Hash.new()
      @cube['assignees'] = Hash.new()
      @cube['sprints'] = Hash.new()

      boards = Board.includes(:stories, :sprints => [:sprint_stories, :changes])
      boards.each &method(:process_board)

      output_to_file("foo.json", boards)

  end


  def processBoard(board)
      board.sprints.each &method(:process_sprint)
  end

  def processSprint(sprint)

      sprint.init_velocity = 0
      sprint.total_velocity = 0
      sprint.estimate_changed_velocity = 0
      sprint.added_velocity = 0

      sprint.init_commitment = 0
      sprint.total_commitment = 0

      sprint.sprint_stories.each { |sstory|

        sprint.init_commitment += (sstory.init_size || 0) unless sstory.was_added
        sprint.total_commitment += (sstory.size || 0)

        if sstory.is_done && sstory.assignee

          wa = WorkActivity.find_by_assignee_id_and_sprint_id(sstory.assignee.id, sprint.id)

          unless wa
            wa = WorkActivity.new()
            wa.story_points = 0
            wa.task_hours = 0
            wa.assignee = sstory.assignee
            wa.board = sprint.board
            wa.sprint = sprint
            wa.pid = board.pid + '_' + sprint.pid + '_' + sstory.assignee.pid
          end

          wa.story_points += sstory.size
          wa.save()
        end
        sstory.save()
      }
      sprint.save()

  end


end
