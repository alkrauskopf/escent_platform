class RedoFolders < ActiveRecord::Migration
  def self.up

    remove_column  :folders, :folderable_id
    remove_column  :folders, :folderable_type
    remove_column  :folders, :abbrev
    add_column  :folders, :coop_app_id,  :integer
    add_column  :folders, :organization_id,  :integer
    add_column  :folders, :position,  :integer

    add_column  :coop_apps, :is_folderable, :boolean, :default => false

    add_index   :folders, :coop_app_id    
    add_index   :folders, :organization_id     

  end

  def self.down

    remove_column  :folders, :position
    remove_column  :folders, :organization_id
    remove_column  :folders, :coop_app_id
    add_column  :folders, :abbrev, :string
    add_column  :folders, :folderable_type, :string
    add_column  :folders, :folderable_id,  :integer

  end
end
