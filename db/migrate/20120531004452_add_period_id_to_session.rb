class AddPeriodIdToSession < ActiveRecord::Migration
  def self.up

   add_column :tlt_sessions, :classroom_period_id, :integer

    add_index :tlt_sessions, :classroom_period_id
  end

  def self.down

   remove_column :tlt_sessions, :classroom_period_id

  end
end
