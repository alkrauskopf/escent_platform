class GenerifyStyleSettings < ActiveRecord::Migration
  def self.up
    rename_table :style_setting_values, :setting_values
    rename_table :style_settings, :settings
    add_column   :settings, :type, :string, :limit => 64
    rename_column :setting_values, :style_setting_id, :setting_id
  end

  def self.down
    remove_column :settings, :type
    rename_column :setting_values, :setting_id, :style_setting_id
    rename_table :setting_values,:style_setting_values
    rename_table :settings, :style_settings
    
  end
end
