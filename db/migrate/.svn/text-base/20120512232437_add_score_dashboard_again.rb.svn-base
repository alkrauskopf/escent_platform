class AddScoreDashboardAgain < ActiveRecord::Migration
  def self.up
    
    add_column :tlt_dashboards, :score_count, :integer

    execute "UPDATE tlt_dashboards SET score_count = 1"


  end

  def self.down
    remove_column :tlt_dashboards, :score_count 
  end
 end
