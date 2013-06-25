class CreateWorkActivities < ActiveRecord::Migration
  def change
    create_table :work_activities do |t|
      t.string :pid
      t.integer :story_points
      t.integer :task_hours
      t.string  :story_type
      t.integer :sprint_id
      t.integer :board_id
      t.integer :assignee_id

      t.timestamps
    end
  end
end
