class OutputAgileData

  def initialize(boards)
    @boards = boards
  end

  def output_to_file(file_name)
    @file = File.open(file_name, 'w')
    @out_boards = Hash.new()
    @out_sprints = Hash.new()
    @out_stories = Hash.new()
    @out_sprint_stories = Hash.new()
    @out_subtasks = Hash.new()
    @out_assignees = Hash.new()
    @out_reporters = Hash.new()
    @out_work_activities = Hash.new()
    @out_changes = Hash.new()

    @boards.each { |board| process_board(board) }

    output = Hash.new()

    output['boards'] = @out_boards
    output['sprints'] = @out_sprints
    output['stories'] = @out_stories
    output['sprintStories'] = @out_sprint_stories
    output['subtasks'] = @out_subtasks
    output['assignees'] = @out_assignees
    output['reporters'] = @out_reporters
    output['workActivities'] = @out_work_activities
    output['changes'] = @out_changes

    @file.write(output.to_json)
  end

  def end
    @file.close()
  end


  def assign_ids_and_process(src_object, destination, process_object, src_symbol, output_name = nil)

    output_name = src_symbol.to_s unless output_name
    destination[output_name] = Hash.new()

    src_object.send(src_symbol).each do |object|
      destination[output_name][object.pid] = object.pid
      process_object.call(object)
    end

  end

  def process_board(board)
    if @out_boards[board.pid]
      return @out_boards[board.pid]
    end

    output = Hash.new()

    output['id'] = board.id
    output['pid'] = board.pid
    output['isSprintBoard'] = board.is_sprint_board
    output['name'] = board.name

    assign_ids_and_process(board, output,  method(:process_sprint), :sprints)
    assign_ids_and_process(board, output,  method(:process_story), :stories)
    assign_ids_and_process(board, output,  method(:process_change), :changes)
    assign_ids_and_process(board, output,  method(:process_work_activity), :work_activities, 'workActivities')

    @out_boards[board.pid] = output
    output
  end

  def process_sprint(sprint)
    if @out_sprints[sprint.pid]
      return @out_sprints[sprint.pid]
    end

    output = Hash.new()
    output['id'] = sprint.id
    output['pid'] = sprint.pid
    output['closed'] = sprint.closed
    output['startDate'] = sprint.start_date
    output['endDate'] = sprint.end_date
    output['haveAllChanges'] = sprint.have_all_changes
    output['haveProcessedAllChanges'] = sprint.have_processed_all_changes
    output['name'] = sprint.name
    output['velocity'] = sprint.velocity
    output['initVelocity'] = sprint.init_velocity
    output['totalVelocity'] = sprint.total_velocity
    output['estimateChangedVelocity'] = sprint.estimate_changed_velocity
    output['addedVelocity'] = sprint.added_velocity
    output['initCommitment'] = sprint.init_commitment
    output['totalCommitment'] = sprint.total_commitment

    assign_ids_and_process(sprint, output,  method(:process_sprint_story), :sprint_stories, 'sprintStories')
    assign_ids_and_process(sprint, output,  method(:process_change), :changes)
    assign_ids_and_process(sprint, output,  method(:process_story), :stories)
    assign_ids_and_process(sprint, output,  method(:process_work_activity), :work_activities, 'workActivities')
    assign_ids_and_process(sprint, output,  method(:process_assignee), :assignees)
    assign_ids_and_process(sprint, output,  method(:process_reporter), :reporters)

    @out_sprints[sprint.pid] = output
    output
  end

  def process_sprint_story(sprint_story)
    if @out_sprint_stories[sprint_story.pid]
      return @out_sprint_stories[sprint_story.pid]
    end

    output = Hash.new()

    output['id'] = sprint_story.id
    output['pid'] = sprint_story.pid
    output['acuity'] = sprint_story.acuity
    output['isDone'] = sprint_story.is_done
    output['location'] = sprint_story.location
    output['size'] = sprint_story.size
    output['initSize'] = sprint_story.init_size
    output['initDate'] = sprint_story.init_date
    output['status'] = sprint_story.status
    output['wasAdded'] = sprint_story.was_added
    output['wasRemoved'] = sprint_story.was_removed
    output['isInitialized'] = sprint_story.is_initialized

    output['storyId'] = sprint_story.story.id
    output['sprintId'] = sprint_story.sprint.id

    output['assigneeId'] = sprint_story.assignee.id if sprint_story.assignee
    output['reporterId'] = sprint_story.reporter.id if sprint_story.reporter
    output['workActivityId'] = sprint_story.work_activity.id if sprint_story.work_activity

    @out_sprint_stories[sprint_story.pid] = output

    output
  end

  def process_story(story)
    if @out_stories[story.pid]
      return @out_stories[story.pid]
    end

    output = Hash.new()
    output['id'] = story.id
    output['pid'] = story.pid
    output['acuity'] = story.acuity
    output['create_date'] = story.create_date
    output['done'] = story.done
    output['done_date'] = story.done_date
    output['location'] = story.location
    output['pid'] = story.pid
    output['size'] = story.size
    output['name'] = story.name
    output['description'] = story.description
    output['status'] = story.status
    output['assignee_id'] = story.assignee_id
    output['reporter_id'] = story.reporter_id
    output['story_type'] = story.story_type

    assign_ids_and_process(story, output,  method(:process_sprint_story), :sprint_stories, 'sprintStories')
    assign_ids_and_process(story, output,  method(:process_subtask), :subtasks)

    @out_stories[story.pid] = output

    output
  end

  def process_assignee(assignee)
    if @out_assignees[assignee.pid]
      return @out_assignees[assignee.pid]
    end

    output = Hash.new()

    process_agile_user(assignee, output)

    assign_ids_and_process(assignee, output,  method(:process_work_activity), :work_activities, 'workActivities')
    assign_ids_and_process(assignee, output,  method(:process_sprint_story), :sprint_stories, 'sprintStories')
    assign_ids_and_process(assignee, output,  method(:process_story), :stories)

    @out_assignees[assignee.pid] = output

    output
  end

  def process_reporter(reporter)
    if @out_reporters[reporter.pid]
      return @out_reporters[reporter.pid]
    end

    output = Hash.new()

    process_agile_user(reporter, output)

    assign_ids_and_process(reporter, output,  method(:process_sprint_story), :sprint_stories, 'sprintStories')
    assign_ids_and_process(reporter, output,  method(:process_story), :stories)

    @out_reporters[reporter.pid] = output

    output
  end


  def process_agile_user(user, output)
    output['id'] = user.id
    output['pid'] = user.pid
    output['displayName'] = user.display_name
    output['emailAddress'] = user.email_address
    output['name'] = user.name
  end

  def process_change(change)
    if @out_changes[change.pid]
      return @out_changes[change.pid]
    end

    output = Hash.new()

    output['id'] = change.id
    output['pid'] = change.pid
    output['action'] = change.action

    output['associated_story_pid'] = change.associated_story_pid
    output['associated_subtask_pid'] = change.associated_subtask_pid

    output['location'] = change.location
    output['new_value'] = change.new_value
    output['old_value'] = change.old_value

    output['board_pid'] = change.board_pid
    output['sprint_pid'] = change.sprint_pid
    output['status'] = change.status
    output['is_done'] = change.is_done
    output['time'] = change.time

    output[change.pid] = output

    output
  end

  def process_work_activity(work_activity)

    if @out_work_activities[work_activity.pid]
      return @out_work_activities[work_activity.pid]
    end

    output = Hash.new()
    output['id'] = work_activity.id
    output['pid'] = work_activity.pid
    output['storyPoints'] = work_activity.story_points
    output['taskHours'] = work_activity.task_hours

    output['assignee_id'] = work_activity.assignee_id
    output['board_id'] = work_activity.board_id
    output['sprint_id'] = work_activity.sprint_id

    assign_ids_and_process(work_activity, output,  method(:process_sprint_story), :sprint_stories, 'sprintStories')

    @out_work_activities[work_activity.pid] = output

    output
  end

  def process_subtask(subtask) end

end