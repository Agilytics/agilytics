require 'rubygems'
require 'httparty'

class SprintController < ApplicationController

  def initialize
    super
    @jira = JiraCaller.new
  end

  def metrics
  end

  def grid
    render :json => @jira.getGridOfBoardAndSprints
  end

  def gridChanges
    #render :json => @jira.getChangesForGridOfBoardAndSprints(params["_json"])
    grid = Board.all
    @jira.getChangesForGridOfBoardAndSprints(grid)
    render :json => grid
  end

  def gridUpdateData
    grid = @jira.getGridOfBoardAndSprints
    grid = @jira.getChangesForGridOfBoardAndSprintsFromObj(grid)
#    grid = @jira.getChangesForGridOfBoardAndSprints(params["_json"])

    grid.each do |board|
        binding.pry
        board.save()
    end

    render :json => ""
  end


  def boards
    render :json => Board.all
  end

  def sprint
    render :json => @jira.getSprint(params[:boardId])
  end

  def changes
    render :json => @jira.getChanges(17, params[:sprintId])
  end

end

class JiraCaller

  include HTTParty

  basic_auth 'ahuffman', 'BlueBird22'
  base_uri 'https://shareableink.atlassian.net'

  def getChanges(boardId, sprintID)

    response = self.class.get("/rest/greenhopper/1.0/rapid/charts/scopechangeburndownchart.json?rapidViewId=#{boardId}&sprintId=#{sprintID}")

    case response.code
      when 200
        response
      when 404
        binding.pry
        []
      else
        binding.pry
        []
    end
  end

  def jId o
    o[:jid] = o["id"]
    o["id"] = nil
  end

  def getChangesForGridOfBoardAndSprintsFromObj(grid)
    boards = Array.new
    grid.each do |board|

      sprintData = board[:sprints]
      board[:sprints] = nil
      jId(board)
      newBoard = Board.new(board)
      boards << newBoard
      sprintData.each do |sprint|

        jId(sprint)

        newSprint = newBoard.sprints.new(sprint)
        changeset = getChanges board[:jid], sprint[:jid]

        changeset[:sprint] = newSprint
        new_changeset = Changeset.new(changeset)
        newSprint.changeset = new_changeset

        processChanges newSprint

      end
    end
    boards
  end

  def getChangesForGridOfBoardAndSprints(grid)
    grid.each do |board|
      board.sprints.each do |sprint|
#        sprint[:change_set] = getChanges board[:id], sprint["id"]
        processChanges sprint
#        getAssignee sprint
      end
    end
    grid
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

  def setSizeOfStory(curStory, o1)

    if o1["statC"] && o1["statC"]["newValue"]
      curStory.size = o1["statC"]["newValue"]
    end

    if o1["statC"] && ( o1["statC"]["newValue"] || o1["statC"]["noStatsValue"] )
      unless curStory.is_initialized
        if o1["statC"]["noStatsValue"]
          curStory.init_size = 0
          curStory.size = 0
        else
          curStory.init_size = o1["statC"]["newValue"] || curStory.size
        end
        curStory.is_initialized = true
      end
    end

  end

  def setIsStoryDone(curStory, o1)

    if o1["column"]
      curStory.done = !o1["column"]["notDone"]
    end

  end

  def setIfAddedOrRemoved(curStory, o1, timestamp, sprint)

    if o1["added"]

      storyAddedDate = Time.at Integer(timestamp)
      curStory.init_date = storyAddedDate
      startTime = Time.at sprint.changeset.startTime
      curStory.was_added = storyAddedDate > startTime
      curStory.was_removed = false
    end

    if o1["added"] == false
      curStory.was_removed = true
    end

  end

  def processChanges(sprint)

    ch = sprint.changeset[:changes]

    ch.keys.each do |timestamp|
      ch[timestamp].each do |o1|

        curStory = getOrCreateStoryOnSprint(sprint, o1["key"], timestamp)
        setSizeOfStory(curStory, o1)
        setIsStoryDone(curStory, o1)
        setIfAddedOrRemoved(curStory, o1, timestamp, sprint)

      end
    end
  end

  def getGridOfBoardAndSprints
    grid = Array.new
    boards = getBoards
    boards["views"].each do |board|
      sprints = getSprint board["id"].to_s
      board[:sprints] = sprints["sprints"]
      grid.push board
    end
    grid
  end

  def getSprints(boardIds)

    array = Array.new

    boardIds.each { |boardId|
      o = getSprint boardId.to_s
      array.push o
    }

    array
  end

  def getSprint(boardId)
    response = self.class.get('/rest/greenhopper/1.0/sprints/' + boardId)
    case response.code
      when 200
        response
      when 404
        binding.pry
        []
      else
        binding.pry
        []
    end
  end

  def getBoards
    response = self.class.get("/rest/greenhopper/1.0/rapidviews/list.json")
    case response.code
      when 200
        response
      when 404
        binding.pry
        []
      else
        binding.pry
        []
    end
  end

end