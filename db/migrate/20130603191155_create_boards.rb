class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :pid
      t.string :name
      t.boolean :to_analyze
      t.boolean :to_analyze_backlog
      t.datetime :last_updated

      t.timestamps
    end
  end
end
