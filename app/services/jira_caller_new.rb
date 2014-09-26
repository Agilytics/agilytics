class JiraCallerNew

  def lputs(str)
    puts str
  end

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
    lputs "getting -> #{uri}"
    response = @rest_caller.http_get(uri)
    if_success_block ||= lambda { |response| response }

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

    http_get("#{@site}/rest/greenhopper/1.0/rapidview") { |response|
      boards = map_boards response['views']
      add_sprints boards
    }
  end

  def map_boards (jira_boards)
    boards = Array.new()
    jira_boards.each do |jb|
      lputs jb['name'] + " " + jb['id'].to_s
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
    url = "#{@site}/rest/greenhopper/1.0/sprintquery/#{boardId}?includeHistoricSprints=true&includeFutureSprints=true"
    puts "****"
    puts url
    puts "****"
    http_get(url)
  end

  def add_or_create_sprint(board, sprint_json)
    # only process closed sprints
    if sprint_json['state'] != 'CLOSED' && sprint_json['id'].to_s != '210'
      return
    end

    sprint_json_pid = board.pid + sprint_json['id'].to_s
    sprint = Sprint.where(pid: sprint_json_pid).first

    unless sprint
      sprint = Sprint.new
      # sprint ids are not unique across boards in JIRA
      sprint.to_analyze = true
      sprint.pid = sprint_json_pid
      sprint.sprint_id = sprint_json['id'].to_s
      board.sprints << sprint
      board.save()
    end

    sprint.name = sprint_json['name']
    sprint.closed = true
    sprint.save()

  end

  def process_sprints

    Sprint.where(to_analyze: true).all().each do |sprint|

      response = get_stories(sprint.board.pid, sprint.sprint_id)


      if response["contents"]
        process_stories(sprint, SprintStory::COMPLETED, response["contents"]["completedIssues"])
        process_stories(sprint, SprintStory::NOT_COMPLETED, response["contents"]["incompleteIssues"])
        process_stories(sprint, SprintStory::PUNTED, response["contents"]["puntedIssues"])
      end

      sprint.start_date = DateTime.parse response["sprint"]["startDate"]
      sprint.end_date = DateTime.parse response["sprint"]["endDate"]
      sprint.closed_date = DateTime.parse response["sprint"]["closedDate"] if response["sprint"]["closedDate"]

      sprint.to_analyze = false
      sprint.save()

    end
  end

  def process_stories(sprint, status, json_stories)
    count = {count: 0}
    if json_stories
      json_stories.each do |json_story|
        lputs json_story["key"]
        sprint_story_pid = sprint.pid + json_story["key"] + status
        found = SprintStory.find_all_by_pid(sprint_story_pid).first()

        unless found
          ss = SprintStory.new
          ss.is_done = json_story["done"]
          ss.status = status
          ss.pid = sprint_story_pid
          ss.sprint = sprint
          ss.save()

          ss.story = process_story(ss, json_story, count, sprint, status)
          sprint.save()

        else
          puts "FOUND"
        end
      end
    end
  end

  def add_tag_to_sprint_stories(story, tag)
      for ss in story.sprint_stories
        ss.tags << tag unless ss.tags.include? tag
        ss.save()
        tag.save()
      end
  end

  def add_labels(story, labels)
    for label in labels

      label_name = "#{Tag::LABEL}:#{label}"

      tag = get_or_create_tag(label_name)

      add_tag_to_sprint_stories(story, tag)

    end
  end

  def update_all_stories()
    for story in Story.all()
      if story.updated_at < Date.today()
        update_story story
        story.save()
      end
    end
  end

  def update_story(story)

      http_get("#{@site}/rest/api/2/issue/#{story.pid}", Object.new) do |json_story_details|

        story.create_date = json_story_details['created']
        story.pid = json_story_details['id']
        story.story_key = json_story_details['key']

        fields = json_story_details['fields']

        if fields

          story.size = fields['customfield_10004']

          story.name = fields['summary']
          story.description = fields['description']

          reporter = get_or_create_user(fields['reporter'], Reporter)
          story.reporter = reporter

          assignee = get_or_create_user(fields['assignee'], Assignee)
          story.assignee = assignee

          story.story_type = fields['issuetype']['name'] if fields['issuetype']
          tag = get_or_create_tag("#{Tag::TYPE}:#{story.story_type}")

          add_tag_to_sprint_stories(story,tag)

          assignee.save() if assignee
          puts "(skip : NIL assignee : for story: #{story.pid} assignee: #{fields['assignee']}" unless assignee

          reporter.save() if reporter
          puts "(skip) : NIL reporter : for story: #{story.pid} reporter: #{fields['assignee']}" unless reporter

          add_labels story, fields['labels']
          tag.save()

          story.updated_at = Date.today
          story.save()

        end
      end

  end

  def process_story(sprint_story, json_story, count, sprint, status)

    story = Story.find_by_pid(json_story['id'].to_s)
    story = Story.new unless story
    story.pid = json_story['id'].to_s
    story.sprint_stories << sprint_story
    sprint_story.save()
    story.save()

    update_story story

    # this gives a snapshot of the story size
    sprint_story.size = story.size

    sprint_story.reporter = story.reporter
    sprint_story.assignee = story.assignee

    sprint_story.save()

    story.save()
    story
  end

  def get_or_create_tag(tagName)
    tag = Tag.find_by_name(tagName)
    unless tag
      tag = Tag.new()
      tag.name = tagName
      tag.save()
    end
    tag
  end

  def get_stories(board_id, sprint_id)
    lputs "#{@site}/rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=#{board_id}&sprintId=#{sprint_id}"
    http_get "#{@site}/rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=#{board_id}&sprintId=#{sprint_id}",
             {contents: {completedIssues: [], incompleteIssues: [], puntedIssues: []}}
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