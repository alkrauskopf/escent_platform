class CreateStyleSettings < ActiveRecord::Migration
  def self.up
    create_table :style_settings, :force => true do |t|
      t.string  "name",                                                                                            :null => false
      t.string  "setting_type", :default => 'String'
      t.string  "group_name"
      t.integer "position",     :limit => 10
      t.string  "default_value"
    end
    
    create_table :style_setting_values, :force => true do |t|
      t.integer "style_setting_id"
      t.integer "scope_id",     :limit => 10,                                                                      :null => false
      t.string  "scope_type",   :limit => 32
      t.string  "value",        :limit => 1024
      t.timestamps
    end
    add_index :style_setting_values, [:scope_id, :scope_type, :style_setting_id], :name => ":scope_id_and_scope_type_and_style_setting_id"
  end

  def self.down
    drop_table :style_settings
    drop_table :style_setting_values
  end
end
