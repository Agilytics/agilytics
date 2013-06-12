require 'rubygems'

class ImportController < ApplicationController

  def initialize
    super
  end

  def updateAll
    grid = AgileData.new
    grid.create
    grid.save
    render :json => '{}'
  end

end

