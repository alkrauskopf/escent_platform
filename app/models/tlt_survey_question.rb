class TltSurveyQuestion < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :tlt_survey_range_type
  belongs_to :organization
  belongs_to :user
  belongs_to :tlt_survey_audience
  belongs_to :tlt_survey_type
  belongs_to :coop_app
      
  has_many :tlt_survey_responses, :dependent => :destroy   

  scope :for_audience, lambda{|audience| {:conditions => ["tlt_survey_audience_id = ? ", audience.id]}}
  scope :active,   :conditions => { :is_active => true }, :order => "position"
  scope :inactive,   :conditions => { :is_active => false }, :order => "position"
  scope :for_type, lambda{|s_type| {:conditions => ["tlt_survey_type_id = ? ", s_type.id]}}
  scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id]}}
  scope :by_position, :order => "position"
end
