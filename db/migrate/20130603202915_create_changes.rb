class CreateChanges < ActiveRecord::Migration
  def change
    create_table :changes do |t|
      t.string :action
      t.string :pid
      t.datetime :time
      t.string :board_pid
      t.string :sprint_pid
      t.string :location
      t.string :status
      t.string :associated_story_pid
      t.string :associated_subtask_pid
      t.string :new_value
      t.string :old_value
      t.integer :board_id
      t.integer :sprint_id
      t.boolean :is_done

      t.timestamps
    end
  end
end
