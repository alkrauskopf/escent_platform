class AddMoreOptionsToActAppOptions < ActiveRecord::Migration
  def self.up
    add_column :act_app_options, :std_dashboard_threshold, :decimal, :precision=>3, :scale => 2
    add_column :act_app_options, :sms_h_threshold, :decimal, :precision=>3, :scale => 2
    execute "UPDATE act_app_options SET std_dashboard_threshold = 1.0"
    execute "UPDATE act_app_options SET sms_h_threshold = 0.75" 
  
  end

  def self.down
    remove_column :act_app_options, :std_dashboard_threshold
    remove_column :act_app_options, :sms_h_threshold
  end
end
