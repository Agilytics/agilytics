class SitesController < ApplicationController
  def index
    sites = Site.find_by_sql 'select
                                s.name,
                                s.id,
                                count(1) as numberOfBoards
                              from
                                sites s
                                join boards b on s.id = b.site_id
                              group by
                                  s.name,
                                  s.id
                              order by s.name'

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: sites }
    end
  end
end