class CreateSprints < ActiveRecord::Migration
  def change
    create_table :sprints do |t|
      t.string :pid
      t.string :name
      t.boolean :closed

      t.boolean :have_all_changes
      t.boolean :have_processed_all_changes
      t.datetime :start_date
      t.datetime :end_date
      t.integer :board_id


      t.integer :init_velocity
      t.integer :added_velocity
      t.integer :estimate_changed_velocity
      t.integer :total_velocity
      t.integer :removed_committed_velocity
      t.integer :removed_added_velocity

      t.integer :init_commitment
      t.integer :added_commitment
      t.integer :estimate_changed
      t.integer :total_commitment

      t.integer :missed_init_commitment
      t.integer :missed_added_commitment
      t.integer :missed_estimate_changed
      t.integer :missed_total_commitment


      t.timestamps
    end
  end
end
