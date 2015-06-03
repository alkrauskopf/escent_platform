class ExpandDescriptionColumnInChannels < ActiveRecord::Migration
  def self.up
    change_column :channels, :title, :string, :limit => 255
    change_column :channels, :description, :string, :limit => 8000
    remove_column :contents, :discussion_content
    add_index :channels, [:organization_id, :type]
    add_index :channels, [:parent_id, :type]
  end

  def self.down
    change_column :channels, :title, :string, :limit => 150
    change_column :channels, :description, :string, :limit => 500
    add_column :contents, :discussion_content, :boolean, :default => false
    remove_index :channels, [:organization_id, :type]
    remove_index :channels, [:parent_id, :type]
  end
end
