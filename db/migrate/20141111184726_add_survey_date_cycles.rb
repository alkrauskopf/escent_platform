class AddSurveyDateCycles < ActiveRecord::Migration
  def self.up
    add_column :elt_cycles, :survey_school_date, :date
  end

  def self.down
    remove_column :elt_cycles, :survey_school_date
  end
end
