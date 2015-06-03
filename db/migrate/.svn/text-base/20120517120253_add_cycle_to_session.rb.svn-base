class AddCycleToSession < ActiveRecord::Migration
  def self.up

   add_column :tlt_sessions, :tlt_cycle_id, :integer

    add_index :tlt_sessions, :tlt_cycle_id
   execute "UPDATE tlt_sessions SET tlt_cycle_id = 1"
  end

  def self.down

remove_column :tlt_sessions, :tlt_cycle_id

  end
end
