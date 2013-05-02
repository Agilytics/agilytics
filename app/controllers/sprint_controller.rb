require 'rubygems'
require 'httparty'

class SprintController < ApplicationController 

  def initialize 
    super
    @jira = JiraCaller.new
  end

  def metrics
  end

  def boards 
    render :json => @jira.getBoards
  end

  def sprints
    render :json => @jira.getSprints(params[:boardId])
  end

  def changes
    render :json => @jira.getChanges(params[:sprintId])
  end


end


class JiraCaller 

  include HTTParty

  basic_auth 'ahuffman', 'BlueBird22'
  base_uri 'https://shareableink.atlassian.net'

  def getChanges(sprintID)
    self.class.get("/rest/greenhopper/1.0/rapid/charts/scopechangeburndownchart.json?rapidViewId=17&sprintId=#{sprintID}")
  end

  def getSprints(boardId)
    self.class.get('/rest/greenhopper/1.0/sprints/' + boardId)
  end

  def getBoards
    self.class.get("/rest/greenhopper/1.0/rapidviews/list.json")
  end


end