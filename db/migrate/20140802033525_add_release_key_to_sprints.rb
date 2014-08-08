class AddReleaseKeyToSprints < ActiveRecord::Migration
  def change
    add_column :sprints, :release_id, :integer
    add_column :sprints, :cost, :float
  end
end
