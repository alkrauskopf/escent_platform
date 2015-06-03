class AddDiagColSurveyResp < ActiveRecord::Migration
  def self.up

   add_column :tlt_survey_responses, :tlt_diagnostic_id, :integer

   add_index :tlt_survey_responses, :tlt_diagnostic_id

  end

  def self.down
    remove_column :tlt_survey_responses, :tlt_diagnostic_id
  end
end
