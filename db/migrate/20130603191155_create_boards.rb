class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :pid
      t.string :name
      t.boolean :to_analyze

      t.timestamps
    end
  end
end
