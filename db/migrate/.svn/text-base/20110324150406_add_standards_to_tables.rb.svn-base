class AddStandardsToTables < ActiveRecord::Migration
  def self.up
      
    add_column :act_standards, :standard, :string
    add_column :act_benches, :standard, :string
    add_column :act_app_options, :standard, :string
    execute "UPDATE act_benches SET standard = 'act'"
    execute "UPDATE act_app_options SET standard = 'act'"
  
  end

  def self.down
      
    remove_column :act_standards, :standard
    remove_column :act_benches, :standard
    remove_column :act_app_options, :standard
  end
end
