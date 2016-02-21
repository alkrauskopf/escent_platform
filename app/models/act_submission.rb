class ActSubmission < ActiveRecord::Base

  include PublicPersona


  belongs_to :act_assessment
  belongs_to :user
  belongs_to :classroom
  belongs_to :organization
  belongs_to :act_subject
  
  has_many :act_answers, :dependent => :destroy
  has_many :act_submission_scores, :dependent => :destroy
  has_many :ifa_student_levels, :dependent => :destroy
  has_many :ifa_question_logs, :dependent => :destroy
  
  validates_presence_of :teacher_id, :message => 'You Must Identify Your Teacher' 
  
  scope :final, :conditions => { :is_final => true }
  scope :auto_finalized, :conditions => { :is_auto_finalized => true }
  scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  scope :not_user_dashboarded, :conditions => ["is_user_dashboarded IS NULL"] rescue []
  scope :not_classroom_dashboarded, :conditions => ["is_classroom_dashboarded IS NULL"]rescue []
  scope :not_org_dashboarded, :conditions => ["is_org_dashboarded IS NULL"] rescue []
  scope :since, lambda{| begin_date| {:conditions => ["created_at >= ?", begin_date]}}
  scope :until, lambda{| end_date| {:conditions => ["created_at <= ?", end_date]}}
  scope :for_teacher, lambda{| teacher| {:conditions => ["teacher_id = ?", teacher.id]}}
  scope :for_classroom, lambda{| classroom| {:conditions => ["classroom_id = ?", classroom.id]}}
  scope :for_user, lambda{| user| {:conditions => ["user_id = ?", user.id]}}
  scope :finalized_period, lambda{| period_start, period_end| {:conditions => ["date_finalized >= ? AND date_finalized <= ?", period_start, period_end]}}
  scope :submission_period, lambda{| period_start, period_end| {:conditions => ["created_at >= ? AND created_at <= ?", period_start, period_end]}}
  
  def sms_score(std)
    sms_score = self.act_submission_scores.select{|r| r.act_master_id == std.id}.first rescue nil
    if sms_score
      score = 0
      if sms_score.est_sms
        score = sms_score.est_sms
      end
      if sms_score.final_sms
        score = sms_score.final_sms
      end
    else
      score = 0
    end
    score
  end


end
