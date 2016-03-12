class IfaQuestionLog < ActiveRecord::Base

  include PublicPersona

  belongs_to :act_question
  belongs_to :act_assessment
  belongs_to :act_submission
  belongs_to :organization
  belongs_to :user
  belongs_to :classroom
  belongs_to :act_subject

  scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  scope :for_organization, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}
  scope :for_teacher, lambda{|teach| {:conditions => ["teacher_id = ? ", teach.id]}}
  scope :for_classroom, lambda{|clsrm| {:conditions => ["classroom_id = ? ", clsrm.id]}}
  scope :for_user, lambda{|user| {:conditions => ["user_id = ? ", user.id]}}
  scope :for_assessment, lambda{|assess| {:conditions => ["classroom_id = ? ", assess.id]}}
  scope :calibrated, :conditions => { :is_calibrated => true }
  scope :for_submission, lambda{|submission| {:conditions => ["act_submission_id = ? ", submission.id]}}
  scope :for_question, lambda{|question| {:conditions => ["act_question_id = ? ", question.id]}}
  scope :grade_zero, {:conditions => ["grade_level = ? ", 0]}

  scope :since, lambda{| begin_date| {:conditions => ["created_at >= ?", begin_date]}}
  scope :until, lambda{| end_date| {:conditions => ["created_at <= ?", end_date]}}
  scope :since_date, lambda{|since_date| {:conditions => ["updated_at >= ? ", since_date]}}
  scope :between_these, lambda{|begin_id, end_id| {:conditions => ["id >= ? && id <= ?", begin_id, end_id]}}
  scope :for_csap_level, lambda{|level| {:conditions => ["csap >= ? && csap <= ?", level.lower_score, level.upper_score]}}
  scope :for_csap_grade_level, lambda{|grade, csap_level| {:conditions => ["grade_level = ? && csap >= ? && csap <= ?", grade, csap_level.lower_score, csap_level.upper_score]}}


  scope :since, lambda{|date|
      {:conditions => ["date_taken >= ? ", date], :order => "date_taken ASC" }
      }

  scope :up_to, lambda{|date|
      {:conditions => ["date_taken<= ? ", date], :order => "date_taken ASC" }
      }
  scope :for_period, lambda{|date|
      {:conditions => ["period_end = ? ", date], :order => "date_taken ASC" }
      }


  def self.period_score (entity, subject, period_end, calibrated)
   questions = calibrated ? entity.ifa_question_logs.for_subject(subject).for_period(period_end).calibrated : entity.ifa_question_logs.for_subject(subject).for_period(period_end)
   choices = questions.collect{ |q| q.choices}.compact.sum.to_f
   points = questions.collect{ |q| q.earned_points}.compact.sum
   choices == 0.0 ? 0.0 : (points/choices)
  end
end
