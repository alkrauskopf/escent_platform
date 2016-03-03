class AddAuthorizationLevelOldCol < ActiveRecord::Migration
  def self.up
    add_column :authorizations, :old_level_id, :integer
    execute "UPDATE authorizations SET old_level_id = authorization_level_id"
  end

  def self.down
    remove_column :authorizations, :old_level_id
  end
end
