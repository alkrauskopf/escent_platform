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
  
  named_scope :final, :conditions => { :is_final => true }
  named_scope :auto_finalized, :conditions => { :is_auto_finalized => true } 
  named_scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  named_scope :not_user_dashboarded, :conditions => ['is_user_dashboarded != ? ', true] rescue []
  named_scope :not_classroom_dashboarded, :conditions => ['is_classroom_dashboarded = !? ', true] rescue []
  named_scope :not_org_dashboarded, :conditions => ['is_org_dashboarded != ? ', true] rescue []
  named_scope :since, lambda{| begin_date| {:conditions => ["created_at >= ?", begin_date]}} 
  named_scope :until, lambda{| end_date| {:conditions => ["created_at <= ?", end_date]}} 
  named_scope :for_teacher, lambda{| teacher| {:conditions => ["teacher_id = ?", teacher.id]}} 
  named_scope :for_classroom, lambda{| classroom| {:conditions => ["classroom_id = ?", classroom.id]}} 
  named_scope :for_user, lambda{| user| {:conditions => ["user_id = ?", user.id]}} 
  named_scope :finalized_period, lambda{| period_start, period_end| {:conditions => ["date_finalized >= ? AND date_finalized <= ?", period_start, period_end]}}
  named_scope :submission_period, lambda{| period_start, period_end| {:conditions => ["created_at >= ? AND created_at <= ?", period_start, period_end]}}
  
  def self.not_dashboarded(dashboard_type, entity, start_date, end_date)
    if dashboard_type == 'User'
      dashboards = entity.act_submissions.final.submission_period(start_date, end_date).not_user_dashboarded
    elsif dashboard_type == 'Classroom'
      dashboards = entity.act_submissions.final.submission_period(start_date, end_date).not_classroom_dashboarded
    elsif dashboard_type == 'Organization'
      dashboards = entity.act_submissions.final.submission_period(start_date, end_date).not_org_dashboarded
    else
      dashboards = []
    end
    dashboards
  end

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

  def standard_score(standard)
    score = 0
    unless self.act_assessment.nil?
      score_pct = (self.tot_choices.nil? || (self.tot_choices == 0) || self.tot_points.nil?) ? 0.0 : (self.tot_points/self.tot_choices.to_f)
      delta = (self.act_assessment.upper_score(standard) - self.act_assessment.lower_score(standard)).to_f
      score = self.act_assessment.lower_score(standard) + (delta * score_pct).to_i
    end
    score
  end

  def total_points
    self.act_answers.collect{|a|a.points}.sum rescue 0.0
  end

  def total_choices
    self.act_answers.selected.size rescue 0
  end

end
