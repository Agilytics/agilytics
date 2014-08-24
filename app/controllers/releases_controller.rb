class ReleasesController < ApplicationController
  # GET /releases
  def index

    releases = Release.where({:site_id => params[:site_id], :board_id => params[:board_id].to_i})
      .includes(:sprints)
      .sort! { |a, b| a.release_date <=> b.release_date }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: releases.as_json( include: :sprints ) }
    end

  end

  def delete
    release_id = params[:release][:id]
    site_id = params[:siteId]
    release = Release.find(release_id)

    if(release.site_id == site_id.to_i)
      ActiveRecord::Base.transaction do

        release.sprints.each do |sp|
          sp.release = nil
          sp.save()
        end

        release.sprints.clear()
        release.delete()

      end

      respond_to do |format|
          format.json { head :no_content }
      end
    else
      respond_to do |format|
          format.json { head :no_content }
      end
    end
  end

  # POST /releases.json
  def create
    release = {}
    site_id = params[:siteId].to_i
    ActiveRecord::Base.transaction do
      sprints = params[:release][:sprints]
      params[:release].delete(:sprints)

      board = Board.find(params[:boardId])

      release = Release.new()
      release.release_date = Date.strptime(params[:release][:release_date], "%m/%d/%Y")

      release.name = params[:release][:name]
      release.description = params[:release][:description]
      release.cost = params[:release][:cost]
      release.total_velocity = params[:release][:total_velocity]

      release.site = Site.find(site_id)
      release.board = board

      board.releases << release
      board.save()

      sprints.each do | sprint |

        sp = Sprint.find(sprint[:id])

        if sp.board.site_id == site_id && !sp.release
          release.sprints << sp
          sp.release = release
          sp.save()
        end
      end

      release.save()
    end

    respond_to do |format|
      if release.save
        format.json { render json: release }
      else
        format.json { render json: release.errors, status: :unprocessable_entity }
      end
    end

  end

  # PUT /releases/1
  # PUT /releases/1.json
  def update
    ActiveRecord::Base.transaction do
      site_id = params[:siteId].to_i
      sprints = params[:release][:sprints]
      params[:release].delete(:sprints)

      release = Release.find(params[:release][:id])
      release.release_date = Date.strptime(params[:release][:release_date], "%m/%d/%Y")

      release.name = params[:release][:name]
      release.description = params[:release][:description]
      release.cost = params[:release][:cost]
      release.total_velocity = params[:release][:total_velocity]
      release.sprints.clear()

      sprints.each do | sprint |

        sp = Sprint.find(sprint[:id])

        if sp.board.site_id == site_id && !sp.release
          release.sprints << sp
          sp.release = release
          sp.save()
        end
      end
      release.save()
    end
    respond_to do |format|
        format.json { head :no_content }
    end
  end

end