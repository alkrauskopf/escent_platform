class AddBeginningOfYearToActOption < ActiveRecord::Migration
  def self.up
    add_column :act_app_options, :begin_school_year, :date
  end

  def self.down

    remove_column :act_app_options, :begin_school_year
  
  end
end
