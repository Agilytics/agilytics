require 'caseconverter'
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


    max_date = Date.parse('01-01-1970')
    @out_sprints.keys.each do |key|
        max_date = @out_sprints[key]['endDate'] if @out_sprints[key]['endDate'] && @out_sprints[key]['endDate'] > max_date
    end

    output['endOfLastSprint'] = max_date

    @file.write(output.to_json)
  end

  def end
    @file.close()
  end


  def assign_ids_and_process(src_object, destination, process_object, src_symbol, output_name = nil)

    output_name = src_symbol.to_s unless output_name
    output_name = "#{output_name.singularize()}Ids"

    destination[output_name] = Array.new() unless destination[output_name]

    src_object.send(src_symbol).each do |object|
      unless destination[output_name].include? object.pid
        destination[output_name] << object.pid
      end
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

  def writeOutAttributes(src, output)
    src.attributes.each do |attr_name, attr_value|
      output[CaseConverter.to_lower_camel_case(attr_name)] = attr_value
    end
  end

  def process_sprint(sprint)
    if @out_sprints[sprint.pid]
      return @out_sprints[sprint.pid]
    end

    output = Hash.new()

    writeOutAttributes(sprint, output)

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

    writeOutAttributes(sprint_story, output)
    assign_ids_and_process(sprint_story, output,  method(:process_change), :changes)

    @out_sprint_stories[sprint_story.pid] = output

    output
  end

  def process_story(story)
    if @out_stories[story.pid]
      return @out_stories[story.pid]
    end

    output = Hash.new()
    writeOutAttributes(story, output)

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
    writeOutAttributes(assignee, output)

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
    writeOutAttributes(reporter, output)

    assign_ids_and_process(reporter, output,  method(:process_sprint_story), :sprint_stories, 'sprintStories')
    assign_ids_and_process(reporter, output,  method(:process_story), :stories)

    @out_reporters[reporter.pid] = output

    output
  end


  def process_change(change)
    if @out_changes[change.pid]
      return @out_changes[change.pid]
    end

    output = Hash.new()
    writeOutAttributes(change, output)

    @out_changes[change.pid] = output

    output
  end

  def process_work_activity(work_activity)

    if @out_work_activities[work_activity.pid]
      return @out_work_activities[work_activity.pid]
    end

    output = Hash.new()
    writeOutAttributes(work_activity, output)

    assign_ids_and_process(work_activity, output,  method(:process_sprint_story), :sprint_stories, 'sprintStories')

    @out_work_activities[work_activity.pid] = output

    output
  end

  def process_subtask(subtask)
    output = Hash.new()
    writeOutAttributes(subtask, output)
    assign_ids_and_process(subtask, output,  method(:process_change), :changes)
    output
  end

end