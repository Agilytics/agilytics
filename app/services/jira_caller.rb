class JiraCaller

  include HTTParty

  basic_auth 'ahuffman', 'BlueBird22'
  base_uri 'https://shareableink.atlassian.net'

  def getSprintChanges(boardId, sprintID)

    response = self.class.get("/rest/greenhopper/1.0/rapid/charts/scopechangeburndownchart.json?rapidViewId=#{boardId}&sprintId=#{sprintID}")

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

    response = self.class.get("/rest/api/2/issue/#{storyId}")

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
    response = self.class.get('/rest/greenhopper/1.0/sprints/' + boardId)
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
    response = self.class.get('/rest/greenhopper/1.0/rapidviews/list.json')
    case response.code
    when 200
      response['views']
    when 404
      []
    else
      []
    end
  end

end