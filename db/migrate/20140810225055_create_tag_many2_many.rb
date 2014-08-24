class CreateTagMany2Many < ActiveRecord::Migration

  def self.up
    create_table :sprint_stories_tags, :id => false do |t|
      t.integer :sprint_story_id
      t.integer :tag_id
    end

    add_index :sprint_stories_tags, [:tag_id, :sprint_story_id]
  end

  def self.down
    drop_table :sprint_stories_tags
  end

end