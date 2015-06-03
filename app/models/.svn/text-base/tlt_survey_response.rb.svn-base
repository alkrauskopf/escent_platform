class TltSurveyResponse < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :tlt_session
  belongs_to :tlt_survey_question
  belongs_to :user
  belongs_to :tlt_survey_audience
  belongs_to :tlt_survey_type
  belongs_to :tlt_diagnostic
  belongs_to :organization
  belongs_to :subject_area
  belongs_to :user_dle_plan
  belongs_to :survey_schedule
  
  named_scope :of_score, lambda{|score| {:conditions => ["score = ? ", score]}}
  named_scope :comments_of_score, lambda{|score| {:conditions => ["score = ? AND comment!= ? ", score, ""]}}
  named_scope :for_audience, lambda{|audience| {:conditions => ["tlt_survey_audience_id = ? ", audience.id]}} 
  named_scope :for_type, lambda{|s_type| {:conditions => ["tlt_survey_type_id = ? ", s_type.id]}} 
  named_scope :for_user, lambda{|user| {:conditions => ["user_id = ? ", user.id]}} 
  named_scope :for_question, lambda{|question| {:conditions => ["tlt_survey_question_id = ? ", question.id]}} 
  named_scope :for_organization, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}
  named_scope :between, lambda{|start_date, end_date| {:conditions => ["created_at >= ? AND created_at <= ?", start_date, end_date]}}

  named_scope :ilt_sessions,  {:conditions => ["!tlt_session_id = ? ", nil]}
  named_scope :pd_plans,  {:conditions => ["!user_dle_plan_id = ? ", nil]}
  named_scope :diagnostics,  {:conditions => ["!tlt_diagnostic_id = ? ", nil]} 
end
