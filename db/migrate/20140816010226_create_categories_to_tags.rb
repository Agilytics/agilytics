class CreateCategoriesToTags < ActiveRecord::Migration

  def self.up
    create_table :categories_tags, :id => false do |t|
      t.integer :category_id
      t.integer :tag_id
    end

    add_index :categories_tags, [:tag_id, :category_id]
  end

  def self.down
    drop_table :categories_tags
  end

end