class JiraCallerNew

  def initialize(rest_caller, site, name)
    @site = site

    @siteClass = Site.find_by_url(site)
    unless @siteClass
      @siteClass = Site.new()
      @siteClass.name = name
      @siteClass.url = site
      @siteClass.save()
    end

    @rest_caller = rest_caller
  end

  def http_get(uri, default_arg = [], &if_success_block)
    puts "getting -> #{uri}"
    response = @rest_caller.http_get(uri)
    if_success_block ||= lambda {|response| response }

    case response.code
      when 200
        if_success_block.call response
      when 404
        default_arg
      else
        default_arg
    end
  end

  def get_boards
    http_get("#{@site}/rest/greenhopper/1.0/rapidview"){ |response|
      boards = map_boards response['views']
      add_sprints boards
    }
  end

  def map_boards (jira_boards)
    boards = Array.new()
    jira_boards.each do |jb|
      if jb['sprintSupportEnabled']
        b = Board.find_by_pid((jb['id']).to_s)

        if (!b)
          b = Board.new()
          b.site = @siteClass
          @siteClass.boards << b
          @siteClass.save()
        end

        b.pid = jb['id'].to_s()
        b.name = jb['name']

        boards << b
        b.save()
      end
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

  def get_sprints(boardId)
    http_get("#{@site}/rest/greenhopper/1.0/sprintquery/#{boardId}?includeHistoricSprints=true&includeFutureSprints=true")
  end

  def add_or_create_sprint(board, sprint_json)
    # only process closed sprints
    if sprint_json['state'] != 'CLOSED'
      return
    end

    sprint_json_pid = board.pid + sprint_json['id'].to_s
    sprint = Sprint.where( pid: sprint_json_pid ).first

    unless sprint
      sprint = Sprint.new
      # sprint ids are not unique across boards in JIRA
      sprint.to_analyze = true
      sprint.pid = sprint_json_pid
      puts sprint_json['id'].to_s
      sprint.sprint_id = sprint_json['id'].to_s
      board.sprints << sprint
      board.save()
    end

    sprint.name = sprint_json['name']
    sprint.closed = true
    sprint.save()

  end

  def process_sprints
    Sprint.where(to_analyze: true).all().each do  |sprint|
      response = get_stories( sprint.board.pid, sprint.sprint_id )
      if response["contents"]
        process_stories(sprint, SprintStory::COMPLETED, response["contents"]["completedIssues"] )
        process_stories(sprint, SprintStory::NOT_COMPLETED, response["contents"]["incompleteIssues"])
        process_stories(sprint, SprintStory::PUNTED, response["contents"]["puntedIssues"])
      end
      sprint.to_analyze = false
      sprint.save()
    end
  end

  def process_stories(sprint, status, json_stories)
    if json_stories
      json_stories.each do |json_story|
        puts json_story["key"]
        sprint_story_pid = sprint.pid + json_story["key"]
        unless SprintStory.find_all_by_pid(sprint_story_pid).first()
          ss = SprintStory.new
          ss.is_done = json_story["done"]
          ss.status = status
          ss.pid = sprint_story_pid
          ss.sprint = sprint

          ss.story = process_story(ss, json_story)

          sprint.save()
          ss.save()
        end
      end
    end
  end

  def process_story(sprint_story, json_story)
    story = Story.find_by_pid(json_story['id'].to_s)
    unless story
      json_story_id = json_story["id"]
      http_get("#{@site}/rest/api/2/issue/#{json_story_id}", Object.new) do |json_story_details|
        story = Story.new
        story.create_date = json_story_details['created']
        story.pid = json_story_details['id']
        story.story_key = json_story_details['key']

        fields = json_story_details['fields']
        if fields

          story.size = fields['customfield_10004']

          # this gives a snapshot of the story size
          sprint_story.size = story.size

          story.name = fields['summary']
          story.description = fields['description']

          reporter = get_or_create_user(fields['reporter'], Reporter)
          story.reporter = reporter
          sprint_story.reporter = reporter

          assignee = get_or_create_user(fields['assignee'], Assignee)
          story.assignee = assignee
          sprint_story.assignee = assignee

          story.story_type = fields['issuetype']['name'] if fields['issuetype']
        end

      end
    end
    story.sprint_stories << sprint_story
    story.save()
    story
  end

  def get_stories(board_id, sprint_id)
    http_get "#{@site}/rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=#{board_id}&sprintId=#{sprint_id}",
             { contents: {  completedIssues: [], incompleteIssues: [], puntedIssues: [] }}
  end


#####

  def get_or_create_user(user_blob, userClass)

    unless user_blob
      return nil
    end

    # remove spaces
    user_name = user_blob['name'].tr(' ', '+')
    user = userClass.find_by_pid(user_name) unless user
    unless user
      user = userClass.new()
      user.pid = user_name
    end

    user.display_name = user_blob['displayName']
    user.email_address = user_blob['emailAddress']
    user.name = user_blob['name']

    user.save()

    user
  end

end