class CreateSprintStories < ActiveRecord::Migration
  def change
    create_table :sprint_stories do |t|

      t.string :pid
      t.string :acuity
      t.datetime :create_date
      t.boolean :is_done
      t.integer :size, default: 0
      t.integer :init_size
      t.string :location
      t.string :status
      t.datetime :init_date
      t.boolean :was_added
      t.boolean :was_removed
      t.boolean :is_initialized

      t.integer :story_id
      t.integer :sprint_id

      t.timestamps

    end
  end
end
