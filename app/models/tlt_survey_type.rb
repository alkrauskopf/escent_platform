class TltSurveyType < ActiveRecord::Base

  include PublicPersona

  belongs_to :coop_app
  
  has_many :tlt_survey_questions
  has_many :tlt_survey_responses
  has_many :dle_cycles
  has_many :dle_cycle_orgs

  has_many   :survey_schedules

  has_many   :survey_instructions, :dependent => :destroy
  has_many   :tlt_survey_audiences, :through => :survey_instructions
  
  scope :general,   :conditions => { :abbrev => "GNRL" }
  scope :post_conference,   :conditions => { :abbrev => "POST" }
  scope :observation,   :conditions => { :abbrev => "OBS" }
  scope :process,   :conditions => { :abbrev => "PROC" }
  scope :reflective,   :conditions => { :abbrev => "REF" }
  scope :progress,   :conditions => { :abbrev => "PROG" }
  scope :readiness,   :conditions => { :abbrev => "READY" }
  scope :pre,   :conditions => { :abbrev => "PRE" }
  scope :disc,   :conditions => { :abbrev => "DISC" }
  scope :learn,   :conditions => { :abbrev => "LEARN" }
  scope :post,   :conditions => { :abbrev => "POST" }
  scope :feedback,   :conditions => { :abbrev => "FEED" }

  def notify_default(audience)
    SurveyInstruction.for_type(self).for_audience(audience).first.is_notify rescue false
  end

  def anon_default(audience)
    SurveyInstruction.for_type(self).for_audience(audience).first.is_anon rescue false
  end

  def duration_default(audience)
    SurveyInstruction.for_type(self).for_audience(audience).first.default_days rescue 5
  end

  def response_limit_default(audience)
    SurveyInstruction.for_type(self).for_audience(audience).first.max_responses rescue 0
  end

  def self_survey?(audience)
    SurveyInstruction.for_type(self).for_audience(audience).first.is_self_survey rescue true
  end

  def instruction_for(audience)
    SurveyInstruction.for_type(self).for_audience(audience).first rescue nil
  end

  def general?
    self.abbrev == "APP" 
  end

end
