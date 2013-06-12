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

      t.timestamps

    end
  end
end
