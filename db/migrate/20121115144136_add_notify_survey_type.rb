class AddNotifySurveyType < ActiveRecord::Migration
  def self.up
 
   add_column :tlt_survey_types, :is_notify, :boolean

  end

  def self.down

   remove_column :tlt_survey_types, :is_notify

  end
end
