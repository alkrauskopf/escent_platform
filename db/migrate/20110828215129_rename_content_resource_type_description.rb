class RenameContentResourceTypeDescription < ActiveRecord::Migration
  def self.up

  rename_column :content_resource_types, :description, :descript
  
  end

  def self.down

  rename_column :content_resource_types, :descript, :description
  
  end
end
