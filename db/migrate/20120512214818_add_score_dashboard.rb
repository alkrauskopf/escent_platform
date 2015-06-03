class AddScoreDashboard < ActiveRecord::Migration
  def self.up
    
    add_column :tlt_dashboards, :score_total, :integer

    execute "UPDATE tlt_dashboards SET score_total = involve_all + involve_most + involve_some + involve_few"


  end

  def self.down
    remove_column :tlt_dashboards, :score_total 
  end
end
