class SurveyScheduleTaker < ActiveRecord::Base

  belongs_to :waiting_survey, :class_name => 'SurveySchedule', :foreign_key => "survey_schedule_id" 
  
  belongs_to :taker, :class_name => 'User', :foreign_key => "user_id"


end
