class AddPositionToSurveys < ActiveRecord::Migration
  def self.up
    
    add_column :tlt_survey_questions, :position, :integer

    execute "UPDATE tlt_survey_questions SET position = id"


  end

  def self.down
    remove_column :tlt_survey_questions, :position
  end
end
