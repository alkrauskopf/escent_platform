class CreateTltSurveyQuestions < ActiveRecord::Migration
  def self.up
    create_table :tlt_survey_questions do |t|
      t.integer :organization_id
      t.integer :user_id
      t.integer :tlt_range_type_id
      t.string :type, :limit => 10
      t.string :question, :limit => 64
      t.boolean :is_active, :default => true

      t.timestamps
    end
    add_index :tlt_survey_questions, :organization_id
    add_index :tlt_survey_questions, :user_id
    add_index :tlt_survey_questions, :tlt_range_type_id
  end

  def self.down
    drop_table :tlt_survey_questions
  end
end
