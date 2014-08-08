class AddRunRateCostToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :run_rate_cost, :float
  end
end
