class JiraCaller

  def initialize(rest_caller, site)
    @site = site
    @rest_caller = rest_caller
  end

  def http_get(uri)
    @rest_caller.http_get(uri)
  end

  def get_sprint_changes(boardId, sprint)
    # jira sprint ids are not unique across boards... so have to do this
    sprintpid = sprint.pid[boardId.length..sprint.pid.length]
    response = http_get("#{@site}/rest/greenhopper/1.0/rapid/charts/scopechangeburndownchart.json?rapidViewId=#{boardId}&sprintId=#{sprintpid}")

    #response['changes'].each{ |d| d[1].each { |c|
    #    if c['key'] == 'AP-40'
    #      puts c
    #    end
    #  }
    #};

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
        board.sprints.each do |sprint|
          process_sprint(board, changes, sprint)
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
        sprint.end_date = Time.now()
        sprint.end_date = Time.at(change_set['completeTime']/1000) if change_set['completeTime']
        sprint.start_date = Time.at(change_set['startTime']/1000)

        val.each { |change| process_change(board, change, changes, sprint, stories, subtasks, time) }

      end

      sprint.have_all_changes = true if sprint.closed
      sprint.save()

    end

    board.save()
  end

  def process_change(board, change, changes, sprint, stories, subtasks, time)

    change = make_change(time, change, board, sprint)
    changes << change

    pid = change.associated_story_pid

    if stories.key?(pid)
      story_or_subtask = stories[pid]
    elsif subtasks.key?(pid)
      story_or_subtask = subtasks[pid]
    else
      story_or_subtask = get_or_create_story_or_task(change.associated_story_pid, board)
    end

    if story_or_subtask.instance_of? Subtask
      subtasks[pid] = story_or_subtask
      change.associated_subtask_pid = story_or_subtask.pid
      change.subtask = story_or_subtask
    else
      stories[pid] = story_or_subtask
      timeDate = Time.at time.to_i / 1000
      #if timeDate > sprint.start_date
        sprint_story = get_or_create_sprint_story(sprint, story_or_subtask, timeDate)

        # sprint story pid is a combination of the story & sprint
        change.sprint_story = sprint_story

        sprint_story.pid = sprint.pid + pid
        sprint_story.assignee = story_or_subtask.assignee
        sprint_story.reporter = story_or_subtask.reporter

        sprint_story.set_size_of_story(change)
        sprint_story.set_is_story_done(change)
        sprint_story.set_if_added_or_removed(change)

        sprint_story.save()

      #end


    end
    change.save()
    story_or_subtask.save()

    change.associated_story_pid = story_or_subtask.pid
  end

  protected


  def get_or_create_sprint_story(sprint, story, timeDate)

    # sprint_story pid is a combination of sprint & story pids
    sprint_story_pid = sprint.pid + story.pid

    if sprint.sprint_stories.where(pid: sprint_story_pid).exists?
      sprintStory = sprint.sprint_stories.where(pid: sprint_story_pid).first
    else
      sprintStory = SprintStory.new
      sprintStory.pid = sprint_story_pid
      sprintStory.init_date = timeDate
      sprintStory.init_size = 0

      sprint.sprint_stories << sprintStory
      story.sprint_stories << sprintStory
    end
    sprintStory
  end

  def get_or_create_story_or_task(pid, board)

    # it's active record so just
    story_or_task = Story.find_by_pid(pid) if Story.where(pid: pid).exists?
    unless story_or_task
      story_or_task = Subtask.find_by_pid(pid) if Subtask.where(pid: pid).exists?
    end

    unless story_or_task
      s = get_story_detail(pid)
      fields = s['fields']

      if fields['issuetype']['subtask']
        story_or_task = create_subtask(pid, fields, board)
      else
        story_or_task = create_story(pid, fields, board)
      end

    end

    story_or_task
  end

  def create_subtask(pid, fields, board)
    subtask = Subtask.new()

    story = get_or_create_story_or_task(fields['parent']['key'], board)
    story.subtasks << subtask

    subtask.reporter = get_or_create_user(fields['reporter'], Reporter, @reporters)
    subtask.assignee = get_or_create_user(fields['assignee'], Assignee, @assignees)
    subtask.pid = pid
    subtask.name = fields['name']
    subtask.description = fields['description']
    subtask.acuity = fields['priority']['name']
    subtask.done = fields['status']['name'] == 'Closed'

    subtask.create_date = fields['created'].to_date

    subtask

  end

  def create_story(pid, fields, board)
    story = Story.new()

    story.size = fields['customfield_10004']
    story.reporter = get_or_create_user(fields['reporter'], Reporter, @reporters)
    story.assignee = get_or_create_user(fields['assignee'], Assignee, @assignees)
    story.name = fields['summary']
    story.story_type = Story::STORY
    story.description = fields['description']

    if (fields['priority'])
      story.acuity = fields['priority']['name']
    end

    if (fields['status'])
      story.done = fields['status']['name'] == 'Closed'
    end

    story.create_date = fields['created'].to_date()
    story.pid = pid

    board.stories << story
    story

  end

  def get_or_create_user(user_blob, userClass, collectionOfUserType)

    unless user_blob
      return nil
    end

    # remove spaces
    user_name = user_blob['name'].tr(' ', '+')
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

      if (!b)
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
      sprints['sprints'].each { |s|
        add_or_create_sprint(board, s)
      }
    }
  end

  def add_or_create_sprint(board, sprint_json)
    sprint = nil
    sprint_json_pid = board.pid + sprint_json['id'].to_s()
    board.sprints.each { |local_sprint|
      # sprint ids are not unique across boards in JIRA
      if local_sprint.pid == sprint_json_pid
        sprint = local_sprint
      end
    }

    unless sprint
      sprint = Sprint.new()
      # sprint ids are not unique across boards in JIRA
      sprint.pid = sprint_json_pid
      board.sprints << sprint
    end

    sprint.name = sprint_json['name']
    sprint.closed = sprint_json['closed']
  end


  def make_change(timestamp, change, board, sprint)

    issueId = change['key']

    new_change = Change.new()
    new_change.pid = "#{timestamp.to_s}_#{board.pid}_#{sprint.pid}"

    new_change.time = Time.at(Integer(timestamp)/1000)
    new_change.board = board
    new_change.board_pid = board.pid
    new_change.sprint = sprint
    new_change.sprint_pid = sprint.pid

    new_change.associated_story_pid = issueId

    new_change.determine_type_and_apply(change, sprint)

    new_change.save()

    new_change
  end

end