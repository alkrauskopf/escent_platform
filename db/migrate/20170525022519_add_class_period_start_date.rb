class AddClassPeriodStartDate < ActiveRecord::Migration
  def up
    add_column :classroom_periods, :start_date, :date
    execute "UPDATE classroom_periods SET start_date = created_at"
  end

  def down
    remove_column :classroom_periods, :start_date
  end
end
