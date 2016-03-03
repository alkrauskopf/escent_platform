class CopyOldLevelIdApplScopes < ActiveRecord::Migration
  def self.up
    execute "UPDATE applicable_scopes SET old_level_id = authorization_level_id"
  end

  def self.down
  end
end
