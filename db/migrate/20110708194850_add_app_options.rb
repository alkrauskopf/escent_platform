class AddAppOptions < ActiveRecord::Migration
  def self.up

   add_column :act_app_options, :pct_correct_green, :integer
   add_column :act_app_options, :pct_correct_red, :integer
   execute "UPDATE act_app_options SET pct_correct_green = 80"  
   execute "UPDATE act_app_options SET pct_correct_red = 60"
  end

  def self.down
   remove_column :act_app_options, :pct_correct_green
   remove_column :act_app_options, :pct_correct_red
  end
end
