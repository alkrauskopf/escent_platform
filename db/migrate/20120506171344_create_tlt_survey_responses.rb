class CreateTltSurveyResponses < ActiveRecord::Migration
  def self.up
    create_table :tlt_survey_responses do |t|
      t.integer :tlt_session_id
      t.integer :user_id
      t.integer :tlt_survey_question_id
      t.integer :score
      t.string :comment

      t.timestamps
    end
    add_index :tlt_survey_responses, :tlt_session_id
    add_index :tlt_survey_responses, :user_id
    add_index :tlt_survey_responses, :tlt_survey_question_id

  end

  def self.down
    drop_table :tlt_survey_responses
  end
end
