class RenameSurveyIdDleCycleOrg2 < ActiveRecord::Migration
  def self.up

     rename_column  :dle_cycle_orgs, :tlt_survey_id, :tlt_survey_type_id

  end

  def self.down

     rename_column  :dle_cycle_orgs, :tlt_survey_type_id, :tlt_survey_id

  end
end
