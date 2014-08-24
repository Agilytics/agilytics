class AddTotalVelocityToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :total_velocity, :integer
  end
end
