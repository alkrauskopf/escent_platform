class SurveyInstruction < ActiveRecord::Base

  include PublicPersona

  belongs_to :tlt_survey_audience
  belongs_to :tlt_survey_type
  has_many   :survey_schedules

  scope :for_audience, lambda{|audience| {:conditions => ["tlt_survey_audience_id = ? ", audience.id]}}
  scope :for_type, lambda{|s_type| {:conditions => ["tlt_survey_type_id = ? ", s_type.id]}}



  def display_name
    self.tlt_survey_type.name.titleize + " Survey For " + self.tlt_survey_audience.audience.titleize.pluralize
  end

  def active_questions_for_org(organization)
    organization.tlt_survey_questions.for_audience(self.tlt_survey_audience).for_type(self.tlt_survey_type).active
  end

  def inactive_questions_for_org(organization)
    organization.tlt_survey_questions.for_audience(self.tlt_survey_audience).for_type(self.tlt_survey_type).inactive
  end
  
  def all_questions_for_org(organization)
    self.active_questions_for_org(organization) + self.inactive_questions_for_org(organization)
  end

  def scheduled_survey_for_org(organization)
    organization.survey_schedules.for_audience(self.tlt_survey_audience).for_type(self.tlt_survey_type).active.first rescue nil
  end


end
