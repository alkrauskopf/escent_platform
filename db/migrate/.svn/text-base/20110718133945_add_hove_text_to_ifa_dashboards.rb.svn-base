class AddHoveTextToIfaDashboards < ActiveRecord::Migration
  def self.up

   add_column :ifa_dashboard_cells, :finalized_hover, :text  
   add_column :ifa_dashboard_cells, :calibrated_hover, :text 
  
  end

  def self.down

   remove_column :ifa_dashboard_cells, :finalized_hover
   remove_column :ifa_dashboard_cells, :calibrated_hover
  
  end
end
