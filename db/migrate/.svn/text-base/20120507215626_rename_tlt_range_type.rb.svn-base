class RenameTltRangeType < ActiveRecord::Migration
  def self.up
    rename_column :tlt_survey_questions, :tlt_range_type_id, :tlt_survey_range_type_id
  end

  def self.down
    rename_column :tlt_survey_questions, :tlt_survey_range_type_id, :tlt_range_type_id
  end
end
