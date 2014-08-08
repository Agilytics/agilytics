class CreateRelease < ActiveRecord::Migration
  def change
    create_table :releases do |t|

      t.string :name
      t.text :description
      t.datetime :release_date
      t.integer :site_id
      t.integer :board_id

      t.float :cost

      t.timestamps

    end
  end
end
