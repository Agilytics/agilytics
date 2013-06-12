class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|

      t.string :pid
      t.string :acuity
      t.datetime :create_date
      t.datetime :done_date
      t.boolean :done
      t.integer :size
      t.string :status
      t.string :location
      t.integer :board_id
      t.integer :sprint_id
      t.integer :assignee_id
      t.integer :reporter_id
      t.string :associated_story_pid
      t.string :associated_subtask_pid
      t.string :story_type
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
