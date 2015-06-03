class AddCoopToAuthorizations < ActiveRecord::Migration
  def self.up
     add_column  :authorization_levels, :coop_app_id, :integer
     add_index  :authorization_levels, :coop_app_id
  end

  def self.down
     remove_column  :authorization_levels, :coop_app_id
  end
end
