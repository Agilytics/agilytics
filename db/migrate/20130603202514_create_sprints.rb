class CreateSprints < ActiveRecord::Migration
  def change
    create_table :sprints do |t|
      t.string :pid
      t.string :name
      t.boolean :closed
      t.integer :velocity
      t.boolean :have_all_changes
      t.boolean :have_processed_all_changes
      t.datetime :start_date
      t.datetime :end_date
      t.integer :board_id
      t.integer :init_velocity
      t.integer :total_velocity
      t.integer :estimate_changed_velocity
      t.integer :added_velocity
      t.integer :init_commitment
      t.integer :total_commitment

      t.timestamps
    end
  end
end
