class AddSubjResponses < ActiveRecord::Migration
  def self.up

   add_column :tlt_survey_responses, :subject_area_id, :integer
   add_column :tlt_survey_responses, :organization_id, :integer
 
   add_index :tlt_survey_responses, :subject_area_id
   add_index :tlt_survey_responses, :organization_id
  end

  def self.down

   remove_column :tlt_survey_responses, :subject_area_id
   remove_column :tlt_survey_responses, :organization_id

  end
end
