class AddOwnerToCoopApp < ActiveRecord::Migration
  def self.up
     add_column  :coop_apps, :owner_id, :integer
     add_index  :coop_apps, :owner_id
  end

  def self.down
     remove_column  :coop_apps, :owner_id
  end
end
