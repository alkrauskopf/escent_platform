class AddCycleDates < ActiveRecord::Migration
  def self.up

    add_column :elt_cycles, :begin_date, :date
    add_column :elt_cycles, :end_date, :date
  end

  def self.down
    remove_column :elt_cycles, :begin_date
    remove_column :elt_cycles, :end_date
  end
end
