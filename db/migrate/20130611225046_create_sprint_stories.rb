class CreateSprintStories < ActiveRecord::Migration
  def change
    create_table :sprint_stories do |t|

      t.string :pid
      t.string :acuity
      t.datetime :create_date
      t.boolean :done
      t.integer :size
      t.integer :init_size
      t.string :location
      t.string :status
      t.datetime :init_date
      t.boolean :was_added
      t.boolean :was_removed
      t.boolean :is_initialized

      t.timestamps

    end
  end
end
