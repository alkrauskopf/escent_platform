class AddAltShortNameOrg < ActiveRecord::Migration
  def self.up
    add_column  :organizations, :alt_short_name, :string, :limit=>10    
  end

  def self.down
    remove_column  :organizations, :alt_short_name
  end
end
