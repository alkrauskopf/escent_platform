class AddContentFields < ActiveRecord::Migration
  def self.up
    add_column :contents, :caption, :string, :limit => 255
    add_column :contents, :duration, :integer
    add_column :contents, :source_name, :string, :limit => 255
    add_column :contents, :creator_name, :string, :limit => 255
    add_column :contents, :star_performer, :string, :limit => 255
  end

  def self.down
    remove_column :contents, :caption
    remove_column :contents, :duration
    remove_column :contents, :source_name
    remove_column :contents, :creator_name
    remove_column :contents, :star_performer
  end
end
