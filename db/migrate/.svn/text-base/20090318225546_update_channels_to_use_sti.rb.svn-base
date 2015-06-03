class UpdateChannelsToUseSti < ActiveRecord::Migration
  def self.up
    rename_column :channels, :channel_type_id, :type
    change_column :channels, :type, :string, :limit => 32
    rename_column :channels, :is_searchable, :searchable
  end

  def self.down
    rename_column :channels, :type, :channel_type_id
    change_column :channels, :channel_type_id, :integer
    rename_column :channels, :searchable, :is_searchable
  end
end
