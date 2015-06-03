class SurveyNotification < ActiveRecord::Base

  belongs_to :tlt_survey_type 
  
  belongs_to :tlt_survey_audience 

  named_scope :for_audience, lambda{|audience| {:conditions => ["tlt_survey_audience_id = ? ", audience.id]}} 
  named_scope :for_type, lambda{|s_type| {:conditions => ["tlt_survey_type_id = ? ", s_type.id]}} 

end
