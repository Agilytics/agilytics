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
    render :json => @jira.getChangesForGridOfBoardAndSprints(params["_json"])
  end

  def boards 
    render :json => @jira.getBoards
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
    self.class.get("/rest/greenhopper/1.0/rapid/charts/scopechangeburndownchart.json?rapidViewId=#{boardId}&sprintId=#{sprintID}")
  end

  def getChangesForGridOfBoardAndSprints(grid)
    grid.each do |board|
      board["sprints"].each do |sprint|
        sprint[:changes] = getChanges board[:id], sprint["id"]
      end
    end
    grid
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
    self.class.get('/rest/greenhopper/1.0/sprints/' + boardId)
  end

  def getBoards
    self.class.get("/rest/greenhopper/1.0/rapidviews/list.json")
  end


end