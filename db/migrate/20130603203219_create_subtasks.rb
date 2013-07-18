class CreateSubtasks < ActiveRecord::Migration
  def change
    create_table :subtasks do |t|

      t.string :pid
      t.string :name
      t.string :description
      t.string :acuity
      t.string :associated_story_pid
      t.string :associated_subtask_pid
      t.datetime :create_date
      t.datetime :done_date
      t.boolean :done
      t.integer :size
      t.string :status
      t.string :location
      t.integer :sprint_id
      t.integer :assignee_id
      t.integer :reporter_id
      t.integer :story_id

      t.timestamps
    end
  end
end
