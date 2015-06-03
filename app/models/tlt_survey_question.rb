class TltSurveyQuestion < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :tlt_survey_range_type
  belongs_to :organization
  belongs_to :user
  belongs_to :tlt_survey_audience
  belongs_to :tlt_survey_type
  belongs_to :coop_app
      
  has_many :tlt_survey_responses, :dependent => :destroy   

  named_scope :for_audience, lambda{|audience| {:conditions => ["tlt_survey_audience_id = ? ", audience.id]}}
  named_scope :active,   :conditions => { :is_active => true }, :order => "position"  
  named_scope :inactive,   :conditions => { :is_active => false }, :order => "position" 
  named_scope :for_type, lambda{|s_type| {:conditions => ["tlt_survey_type_id = ? ", s_type.id]}}
  named_scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id]}}
  named_scope :by_position, :order => "position"     
end
