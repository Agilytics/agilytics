class CreateRelease < ActiveRecord::Migration
  def change
    create_table :releases do |t|

      t.string :name
      t.datetime :release_date
      t.integer :site_id

      t.timestamps

    end
  end
end
