class NewFolderIndices < ActiveRecord::Migration
  def self.up

    remove_index   :folders, :coop_app_id    
    add_index   :folders, [:coop_app_id, :organization_id], :name=>"app_organization"
    remove_index   :folders, :organization_id 
    add_index   :folders, [:organization_id, :coop_app_id], :name=>"organization_app"
    remove_column :folders, :position
  end

  def self.down
  
    add_column :folders, :position, :integer
    remove_index   :folders, [:coop_app_id, :organization_id]
    add_index   :folders, :coop_app_id  
    remove_index   :folders, [:organization_id, :coop_app_id]
    add_index   :folders, :organization_id 
    
  end
end
