class IfaQuestionLog < ActiveRecord::Base

  include PublicPersona

  belongs_to :act_question
  belongs_to :act_assessment
  belongs_to :act_submission
  belongs_to :organization
  belongs_to :user
  belongs_to :classroom
  belongs_to :act_subject

  named_scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  named_scope :for_organization, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}
  named_scope :for_teacher, lambda{|teach| {:conditions => ["teacher_id = ? ", teach.id]}}
  named_scope :for_classroom, lambda{|clsrm| {:conditions => ["classroom_id = ? ", clsrm.id]}}
  named_scope :for_user, lambda{|user| {:conditions => ["user_id = ? ", user.id]}}
  named_scope :for_assessment, lambda{|assess| {:conditions => ["classroom_id = ? ", assess.id]}}
  named_scope :calibrated, :conditions => { :is_calibrated => true }
  named_scope :for_submission, lambda{|submission| {:conditions => ["act_submission_id = ? ", submission.id]}}
  named_scope :for_question, lambda{|question| {:conditions => ["act_question_id = ? ", question.id]}}
  named_scope :grade_zero, {:conditions => ["grade_level = ? ", 0]}

  named_scope :since, lambda{| begin_date| {:conditions => ["created_at >= ?", begin_date]}} 
  named_scope :until, lambda{| end_date| {:conditions => ["created_at <= ?", end_date]}} 
  named_scope :since_date, lambda{|since_date| {:conditions => ["updated_at >= ? ", since_date]}}
  named_scope :between_these, lambda{|begin_id, end_id| {:conditions => ["id >= ? && id <= ?", begin_id, end_id]}}
  named_scope :for_csap_level, lambda{|level| {:conditions => ["csap >= ? && csap <= ?", level.lower_score, level.upper_score]}}
  named_scope :for_csap_grade_level, lambda{|grade, csap_level| {:conditions => ["grade_level = ? && csap >= ? && csap <= ?", grade, csap_level.lower_score, csap_level.upper_score]}}


  named_scope :since, lambda{|date| 
      {:conditions => ["date_taken >= ? ", date], :order => "date_taken ASC" }
      }

  named_scope :up_to, lambda{|date| 
      {:conditions => ["date_taken<= ? ", date], :order => "date_taken ASC" }
      }
  named_scope :for_period, lambda{|date| 
      {:conditions => ["period_end = ? ", date], :order => "date_taken ASC" }
      }

end
