class AddAppMethodIdTltActivity < ActiveRecord::Migration
  def self.up
     add_column  :tl_activity_types, :app_method_id, :integer
     add_index  :tl_activity_types, :app_method_id
  end

  def self.down
     remove_column  :tl_activity_types, :app_method_id
  end
end
