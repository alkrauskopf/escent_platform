class AddAppIdSurveyQuestions < ActiveRecord::Migration
  def self.up

    add_column :tlt_survey_questions, :coop_app_id, :integer

    add_index :tlt_survey_questions, :coop_app_id
    execute "UPDATE tlt_survey_questions SET coop_app_id = 6"
    
  end

  def self.down

    remove_column :tlt_survey_questions, :coop_app_id

  end
end
