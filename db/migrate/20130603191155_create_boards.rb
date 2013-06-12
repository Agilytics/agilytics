class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :pid
      t.string :name
      t.boolean :is_sprint_board

      t.timestamps
    end
  end
end
