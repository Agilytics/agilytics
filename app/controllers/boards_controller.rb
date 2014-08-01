class BoardsController < ApplicationController
  # GET /boards
  # GET /boards.json
  def index
    @boards = Board.find_all_by_site_id(params[:site_id]).sort! { |a, b| a.name.downcase <=> b.name.downcase }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @boards }
    end
  end

  # GET /boards/1
  # GET /boards/1.json
  def show
    @board = Board.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @board }
    end
  end

  # GET /boards/new
  # GET /boards/new.json
  def new
    @board = Board.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @board }
    end
  end

  # GET /boards/1/edit
  def edit
    @board = Board.find(params[:id])
  end

  def updateBoards()
    ActiveRecord::Base.transaction do
      params[:boards].each do |jb|

        b = Board.where({id: jb[:id], site_id: params[:siteId]})
        puts " ---------------- #{b.any?}"
        if b.any?
          b = b.first
          puts "#{jb[:id]} #{params[:siteId]} #{b.name} #{b.to_analyze}"

          jb.delete(:id)
          jb.delete(:created_at)
          jb.delete(:id)
          jb.delete(:site_id)
          jb.delete(:updated_at)
          jb.delete("$$hashKey")


          b.update_attributes(jb)

          b.save()
        end
      end
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # PUT /boards/1
  # PUT /boards/1.json
  def update
    @board = Board.find(params[:id])

    respond_to do |format|
      if @board.update_attributes(params[:board])
        format.html { redirect_to @board, notice: 'Board was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boards/1
  # DELETE /boards/1.json
  def destroy
    @board = Board.find(params[:id])
    @board.destroy

    respond_to do |format|
      format.html { redirect_to boards_url }
      format.json { head :no_content }
    end
  end


  def velocities
    boards = Hash.new
    site_id = params[:site_id]

    ActiveRecord::Base.connection.execute("
      SELECT
             TO_NUMBER(sp.sprint_id, '999999') as id,
             sp.board_id,
             sp.name,
             SUM(s.size) AS total_velocity

     FROM
       stories s
       JOIN sprint_stories ss ON ss.story_id = s.id
       JOIN sprints sp ON ss.sprint_id = sp.id
       JOIN boards b on b.id = sp.board_id

     WHERE
       ss.status = 'completed'
       AND b.site_id = #{site_id}

     GROUP BY
       sp.board_id,
       sp.name,
       to_number(sp.sprint_id, '999999')

     ORDER BY
       sp.board_id,
       to_number(sp.sprint_id, '999999')
    ").each do |row|
      unless boards[row["board_id"]]
        boards[row["board_id"]] = Hash.new
        boards[row["board_id"]]["sprintVelocities"] = []
      end
      boards[row["board_id"]]["sprintVelocities"] << row["total_velocity"].to_i
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render json: {
            boards: boards
        }
      }
    end
  end


  def stats
    board_id = params[:id]
    site_id = params[:site_id]
    results = []
    board = Board.find_by_id(board_id)
    ActiveRecord::Base.connection.execute("
      select
        t.board_name,
        t.id as sprint_id,
        t.name as sprint_name,
        t.feature_count,
        t.bug_count,
        t.enhancement_count,
        t.total_count,
        CAST(CAST(t.feature_count as float) / t.total_count as float) as feature_percentage_count,
        CAST(CAST(t.bug_count as float)  / t.total_count as float) as bug_percentage_count,
        CAST(CAST(t.enhancement_count as float) / t.total_count as float) as enhancements_percentage_count,
        t.bug_velocity,
        t.feature_velocity,
        t.enhancement_velocity,
        t.total_velocity,
        CAST(CAST(t.feature_velocity as float) / t.total_velocity as float) as feature_percentage_velocity,
        CAST(CAST(t.bug_velocity as float)  / t.total_velocity as float) as bug_percentage_velocity,
        CAST(CAST(t.enhancement_velocity as float) / t.total_velocity as float) as enhancements_percentage_velocity

      from
        (SELECT
           TO_NUMBER(sp.sprint_id, '999999') as id,
           b.name as board_name,
           sp.name,
           SUM(CASE WHEN s.story_type = 'New Feature' THEN 1
               ELSE 0
               END)    AS feature_count,

           SUM(CASE WHEN s.story_type = 'Bug' THEN 1
               ELSE 0
               END)    AS bug_count,

           SUM(CASE WHEN s.story_type = 'Improvement' OR s.story_type = 'Story'  THEN 1
               ELSE 0
               END)    AS enhancement_count,

           SUM(CASE WHEN s.story_type = 'New Feature' THEN s.size
               ELSE 0
               END)    AS feature_velocity,

           SUM(CASE WHEN s.story_type = 'Bug' THEN s.size
               ELSE 0
               END)    AS bug_velocity,

           SUM(CASE WHEN s.story_type = 'Improvement' OR s.story_type = 'Story' THEN s.size
               ELSE 0
               END)    AS enhancement_velocity  ,

           COUNT(1) AS total_count,

           SUM(s.size) AS total_velocity

         FROM
           stories s
           JOIN sprint_stories ss ON ss.story_id = s.id
           JOIN sprints sp ON ss.sprint_id = sp.id
           JOIN boards b ON sp.board_id = b.id

         WHERE
           ss.status = 'completed'
           and b.id = #{board_id}
           and b.site_id = #{site_id}

         GROUP BY
           sp.name,
           b.name,
           to_number(sp.sprint_id, '999999')

         ORDER BY
           b.name,
           to_number(sp.sprint_id, '999999')

        ) as t
    ").each do |row|
      results.push row
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: {
          board: board,
          data: results
      }
      }
    end
  end

end
