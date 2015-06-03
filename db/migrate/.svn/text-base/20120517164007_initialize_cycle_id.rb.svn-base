class InitializeCycleId < ActiveRecord::Migration
  def self.up
 
   add_column :tlt_dashboards, :tlt_cycle_id, :integer

    add_index :tlt_dashboards, :tlt_cycle_id
   execute "UPDATE tlt_dashboards SET tlt_cycle_id = 1"
 
  end

  def self.down

  remove_column :tlt_dashboards, :tlt_cycle_id

  end
end
