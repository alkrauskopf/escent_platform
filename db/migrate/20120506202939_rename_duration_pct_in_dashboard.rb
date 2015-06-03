class RenameDurationPctInDashboard < ActiveRecord::Migration
  def self.up
    rename_column :tlt_dashboards, :durattion_pct, :duration_pct

  end

  def self.down
    rename_column :tlt_dashboards, :duration_pct, :durattion_pct

  end
end
