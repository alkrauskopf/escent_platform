class RemoveTltDashboardCols < ActiveRecord::Migration
  def self.up
   remove_column :tlt_dashboards, :involve_few
   remove_column :tlt_dashboards, :involve_some
   remove_column :tlt_dashboards, :involve_most
   remove_column :tlt_dashboards, :involve_all
   remove_column :tlt_dashboards, :tlt_cycle_id
  end

  def self.down
   add_column :tlt_dashboards, :involve_few, :integer
   add_column :tlt_dashboards, :involve_some, :integer
   add_column :tlt_dashboards, :involve_most, :integer
   add_column :tlt_dashboards, :involve_all, :integer
   add_column :tlt_dashboards, :tlt_cycle_id, :integer
  end
end
