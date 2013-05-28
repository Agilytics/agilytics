require 'rubygems'
require 'httparty'

class SprintController < ApplicationController

  def initialize
    super
  end

  def metrics
  end

  def grid
    render :json => @jira.getGridOfBoardAndSprints
  end

  def gridChanges
    #render :json => @jira.getChangesForGridOfBoardAndSprints(params["_json"])
    grid = Board.all().to_a
    @jira.getChangesForGridOfBoardAndSprints(grid)
    grid.each do |board|
      board.upsert()
    end
    render :json => grid
  end

  def createMasterGrid
    grid = Grid.new
    grid.create
    grid.save
    render :json => grid.model_grid
  end

  def boards
    sleep(1)
    render :json => Board.all
  end

  def sprint
    render :json => @jira.getSprint(params[:boardId])
  end

  def changes
    render :json => @jira.getChanges(17, params[:sprintId])
  end

end

