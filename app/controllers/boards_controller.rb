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
    update = {}
    update[:name] = params[:board][:name]
    update[:run_rate_cost] = params[:board][:run_rate_cost]

    respond_to do |format|
      if @board.update_attributes(update)
        format.html { redirect_to @board, notice: 'Board was successfully updated.' }
        format.json { render json: @board }
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

  def tags
    tags = []
    ActiveRecord::Base.connection.execute("
      select distinct t.* from
      tags t
      join sprint_stories_tags tss on t.id = tss.tag_id
      join sprint_stories ss on tss.sprint_story_id = ss.id
      join sprints sp on ss.sprint_id = sp.id
      join boards b on sp.board_id = b.id
      WHERE
        b.id = #{params[:id]}
                                          ").each do |row|
      tags << row
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render json: {
            tags: tags
        }
      }
    end

  end

  def categories
    board = Board.includes(categories: [:tags]).find(params[:id])
    respond_to do |format|
      format.html { redirect_to boards_url }
      format.json {
        render json: {categories: board.categories}, include: [:tags]
      }
    end
  end

  def delete_category
     ActiveRecord::Base.transaction do
      board = Board.find(params[:id])
      category = Category.find(params[:category_id])
      board.categories.delete category
      board.save()
     end
    respond_to do |format|
      format.html { head :no_content }
      format.json { head :no_content }
    end
  end

  def set_categories
    ActiveRecord::Base.transaction do
      board = Board.find(params[:id])

      params[:categories].each do |categoryJ|

        if categoryJ[:id]
          categoryO = Category.find(categoryJ[:id])
        else
          categoryO = Category.new()
        end

        board.categories << categoryO unless categoryO.id && board.categories.find(categoryO.id)

        # add remove all tags
        categoryO.tags.clear()

        categoryO.name = categoryJ[:name]
        if categoryJ[:tags]
          categoryJ[:tags].each do |tagJ|
            tagO = Tag.find(tagJ[:id])
            categoryO.tags << tagO
          end
        end

        categoryO.save()
      end
    end
    respond_to do |format|
      format.html { head :no_content }
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

  def build_where_for_categories(categories)
    tag_ids = ""
    categories.each do |category|
      category.tags.each do |tag|
        tag_ids += "#{tag.id},"
      end
    end
    tag_ids[0..-2]
  end

  def build_case_for_categories(categories, type)

    #counts
    sql_category = ""
    firstCategory = true
    categories.each do |category|

      if firstCategory then
        firstCategory = false
      else
        sql_category += ", "
      end

      sql_category += "\nSUM(CASE WHEN "
      first = true

      category.tags.each do |tag|
        if first then
          first = false
        else
          sql_category += " OR "
        end
        sql_category += "t.id ='#{tag.id}'"
      end
      sql_category += " THEN #{ type == 'count' ? 1 : 's.size' }
              ELSE 0
              END) AS cat_#{category[:id]}_#{type}"
    end
    sql_category
  end


  def stats
    board_id = params[:id]
    site_id = params[:site_id]
    results = []
    board = Board.includes(:categories).find(board_id)

    categories = board.categories

    #[
    #    {
    #        name: 'bug',
    #        labels: ['type:Bug']
    #    },
    #    {
    #        name: 'feature',
    #        labels: ['type:New Feature']
    #    },
    #    {
    #        name: 'enhancement',
    #        labels: ['type:Improvement', 'type:Story']
    #    }
    #]
    unless categories.empty?
      sql = build_case_for_categories(categories, "count")
      sql += ", #{build_case_for_categories(categories, "velocity")}"
      tagids = build_where_for_categories(categories)

      select_SQL = ""
      categories.each do |category|
        select_SQL +=
        "
          t.cat_#{category.id}_count as cat_#{category.id}_count,
          CAST(CAST(t.cat_#{category.id}_count as float) / t.total_count as float) as cat_#{category.id}_percentage_count,
          t.cat_#{category.id}_velocity as cat_#{category.id}_velocity,
          CAST(CAST(t.cat_#{category.id}_velocity as float) / t.total_velocity as float) as cat_#{category.id}_percentage_velocity,

         "
      end

      the_sql =
        "select
            t.board_name,
            t.id as sprint_id,
            t.name as sprint_name,
            t.end_date,
            t.id as id,
            t.pid,
            t.name as name,
            t.total_count,

            #{select_SQL}

            t.total_velocity

          from
            (SELECT
               TO_NUMBER(sp.sprint_id, '999999') as id,
               b.name as board_name,
               sp.name,
               sp.cost,
               sp.pid,
               #{sql},

               COUNT(1) AS total_count,
               SUM(s.size) AS total_velocity,
               sp.end_date


             FROM
               stories s
               JOIN sprint_stories ss ON ss.story_id = s.id
               JOIN sprints sp ON ss.sprint_id = sp.id
               JOIN boards b ON sp.board_id = b.id
               JOIN sprint_stories_tags as sst on sst.sprint_story_id = ss.id
               join tags as t on t.id = sst.tag_id

             WHERE
               ss.status = 'completed'
               and b.id = #{board_id}
               and b.site_id = #{site_id}
               and t.id in (#{tagids})

             GROUP BY
               sp.pid,
               sp.name,
               sp.cost,
               b.name,
               sp.end_date,
               to_number(sp.sprint_id, '999999')

             ORDER BY
               b.name,
               to_number(sp.sprint_id, '999999')

            ) as t"

      ActiveRecord::Base.connection.execute(the_sql).each do |row|
        results.push row
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render json: {
            board: board ,
            data: results
        }, include: [:categories]
      }
    end
  end

end
