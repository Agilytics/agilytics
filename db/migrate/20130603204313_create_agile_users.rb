class CreateAgileUsers < ActiveRecord::Migration
  def change
    create_table :agile_users do |t|
      t.string :pid
      t.string :name
      t.string :display_name
      t.string :email_address

      t.timestamps
    end
  end
end
