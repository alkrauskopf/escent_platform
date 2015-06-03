class RenameFinalizedTltSession < ActiveRecord::Migration
  def self.up
    rename_column :tlt_sessions, :finalized_date, :finalize_date
  end

  def self.down
    rename_column :tlt_sessions, :finalize_date, :finalized_date
  end
end
