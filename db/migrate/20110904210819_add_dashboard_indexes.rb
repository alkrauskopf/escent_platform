class AddDashboardIndexes < ActiveRecord::Migration
  def self.up

    # add_index :ifa_dashboards, [:ifa_dashboardable_type,:ifa_dashboardable_id, :act_subject, :period_end]
  
  end

  def self.down


    # remove_index :ifa_dashboards, [:ifa_dashboardable_type, :ifa_dashboardable_id, :act_subject, :period_end]
    
  end
end
