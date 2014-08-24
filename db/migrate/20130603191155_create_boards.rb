class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :pid
      t.string :name
      t.boolean :to_analyze
      t.boolean :to_analyze_backlog
      t.datetime :last_updated

      t.integer :site_id
      t.float :run_rate_cost

      t.timestamps
    end
  end
end
