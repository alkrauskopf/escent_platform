class TltDiagnostic < ActiveRecord::Base

  include PublicPersona

  belongs_to :user
  belongs_to :organization
  belongs_to :subject_area

  has_many  :tlt_survey_responses, :dependent => :destroy
  has_many :tlt_diagnostic_lessons, :dependent => :destroy
  has_many   :survey_schedules, :as => :entity, :dependent => :destroy    

  scope :for_subject, lambda{|subj| {:conditions => ["subject_area_id = ? ", subj.id]}}
  
end
