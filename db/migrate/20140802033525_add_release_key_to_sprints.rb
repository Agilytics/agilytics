class AddReleaseKeyToSprints < ActiveRecord::Migration
  def change
    add_column :sprints, :release_id, :integer
  end
end
