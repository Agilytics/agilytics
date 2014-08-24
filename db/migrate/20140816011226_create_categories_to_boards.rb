class CreateCategoriesToBoards < ActiveRecord::Migration

  def self.up
    create_table :boards_categories, :id => false do |t|
      t.integer :category_id
      t.integer :board_id
    end

    add_index :boards_categories, [:board_id, :category_id]
  end

  def self.down
    drop_table :boards_categories
  end

end