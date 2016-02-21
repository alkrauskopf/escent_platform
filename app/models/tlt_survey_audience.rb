class TltSurveyAudience < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :coop_app
  has_many :tlt_survey_questions
  has_many :tlt_survey_responses

  has_many   :survey_schedules
  has_many   :survey_instructions, :dependent => :destroy
  has_many   :tlt_survey_types, :through => :survey_instructions
        
  scope :teacher,   :conditions => { :audience => "teacher" }
  scope :observer,   :conditions => { :audience => "observer" }
  scope :student,   :conditions => { :audience => "student" }
  scope :evaluator,   :conditions => { :audience => "evaluator" }
  scope :client,   :conditions => { :audience => "client school" }

  def notify_default(type)
     SurveyInstruction.for_type(type).for_audience(self).first.is_notify rescue false
  end

  def anon_default(type)
     SurveyInstruction.for_type(type).for_audience(self).first.is_anon rescue false
  end

  def duration_default(type)
    SurveyInstruction.for_type(type).for_audience(self).first.default_days rescue 5
  end

  def response_limit_default(type)
    SurveyInstruction.for_type(type).for_audience(self).first.max_responses rescue 0
  end
  
  def self_survey?(type)
    SurveyInstruction.for_type(type).for_audience(self).first.is_self_survey rescue true
  end
  
end
