class AddIfaDashboardIndexes < ActiveRecord::Migration
  def self.up
    add_index :ifa_dashboards, [:ifa_dashboardable_type, :ifa_dashboardable_id, :act_subject_id, :period_end], :name=>"entitytype_id_subject_period"
    add_index :ifa_dashboards, [:organization_id, :act_subject_id, :period_end], :name=>"org_subject_period"
  end

  def self.down
  end
end
