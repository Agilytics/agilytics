class Releases_Controller < ApplicationController
  # GET /boards
  # GET /boards.json
  def index

    releases = Release.find_all_by_site_id(params[:site_id]).sort! { |a, b| a.date <=> b.date }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: releases }
    end

  end

  # POST /releases.json
  def create
    release = Release.new(params[:release])

    respond_to do |format|
      if release.save
        format.json { render json: release, status: :created, location: release }
      else
        format.json { render json: release.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /releases/1
  # PUT /releases/1.json
  def update
    release = Release.find(params[:id])

    respond_to do |format|
      if release.update_attributes(params[:release])
        format.json { head :no_content }
      else
        format.json { render json: release.errors, status: :unprocessable_entity }
      end
    end
  end

end