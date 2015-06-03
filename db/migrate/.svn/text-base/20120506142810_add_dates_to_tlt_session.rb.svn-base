class AddDatesToTltSession < ActiveRecord::Migration
  def self.up
    add_column :tlt_sessions, :review_date, :date
    add_column :tlt_sessions, :finalized_date, :date
    add_column :tl_activity_types, :abbrev, :string
    add_column :tl_activity_type_tasks, :abbrev, :string
  end

  def self.down

    remove_column :tlt_sessions, :review_date
    remove_column :tlt_sessions, :finalized_date
    remove_column :tl_activity_types, :abbrev
    remove_column :tl_activity_type_tasks, :abbrev
  end
end
