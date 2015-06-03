class AddUserCalibrationFilter < ActiveRecord::Migration
  def self.up
   add_column :users, :calibrated_only, :boolean, :default => false
   execute "UPDATE users SET calibrated_only = 0" 
  end

  def self.down
   remove_column :users, :calibrated_only
  
  end
end
