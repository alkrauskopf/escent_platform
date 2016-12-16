class AddRegistrationCode < ActiveRecord::Migration
  def up
    add_column :coop_apps, :registration_code, :string
  end

  def down
    remove_column :coop_apps, :registration_code
  end
end
