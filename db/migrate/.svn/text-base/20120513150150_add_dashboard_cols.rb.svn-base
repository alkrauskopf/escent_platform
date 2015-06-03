class AddDashboardCols < ActiveRecord::Migration
  def self.up

    rename_column :tlt_dashboards, :score_total, :involve_total
    rename_column :tlt_dashboards, :score_count, :involve_count    
    add_column :tlt_dashboards, :impact_total, :integer
    add_column :tlt_dashboards, :impact_count, :integer

    execute "UPDATE tlt_dashboards SET involve_count = 0"
    execute "UPDATE tlt_dashboards SET impact_total = 0"
    execute "UPDATE tlt_dashboards SET impact_count = 0"

  end

  def self.down

    rename_column :tlt_dashboards, :involve_total, :score_total
    rename_column :tlt_dashboards, :involve_count , :score_count   
    remove_column :tlt_dashboards, :impact_total
    remove_column :tlt_dashboards, :impact_count

  end
end
