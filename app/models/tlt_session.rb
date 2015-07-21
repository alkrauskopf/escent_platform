class TltSession < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :user
  belongs_to :classroom
  belongs_to :topic
  belongs_to :content
  belongs_to :tracker, :class_name => 'User', :foreign_key => "tracker_id"
  belongs_to :organization
  belongs_to :subject_area
  belongs_to :classroom_period
  belongs_to :itl_belt_rank
  belongs_to :itl_template
        
  has_one  :tlt_session_video, :dependent => :destroy
  has_many :tlt_session_logs, :dependent => :destroy
  has_many :tlt_survey_responses, :dependent => :destroy   
  has_many :tlt_dashboards, :dependent => :destroy
  has_one  :itl_blackbelt, :dependent => :destroy
  has_many :tlt_session_app_methods, :dependent => :destroy
  has_many :app_methods, :through => :tlt_session_app_methods
  has_many :survey_schedules, :as => :entity, :dependent => :destroy  

  named_scope :final, :conditions => { :is_final => true}
  named_scope :open, :conditions => { :is_final => false}
  named_scope :backlog, :conditions => { :is_final => false}
  named_scope :observer_done, :conditions => { :is_observer_done => true}
  named_scope :teacher_done, :conditions => { :is_teacher_done => true}
  named_scope :observer_backlog, :conditions => { :is_observer_done => false}
  named_scope :teacher_backlog, :conditions => { :is_teacher_done => false}    
  named_scope :completed, :conditions => { :logs_are_closed => true}
  named_scope :of_video, {:conditions => ["content_id >= ?", 1]}  
  named_scope :practice, :conditions => { :is_training => true} 
  named_scope :not_practice, :conditions => { :is_training => false}
  named_scope :blackbelt, :include => :itl_belt_rank, :conditions => ["itl_belt_rank.rank = ?", "black"]
  named_scope :whitebelt, :include => :itl_belt_rank, :conditions => ["itl_belt_rank.rank = ?", "white"]

  
  named_scope :for_subject, lambda{|subject| {:conditions => ["subject_area_id = ? ", subject.id], :order => "created_at DESC"}}
  named_scope :for_observer, lambda{|observer| {:conditions => ["tracker_id = ? ", observer.id], :order => "created_at DESC"}}
  named_scope :for_teacher, lambda{|teacher| {:conditions => ["user_id = ? ", teacher.id], :order => "created_at DESC"}}
  named_scope :for_belt, lambda{|belt| {:conditions => ["itl_belt_rank_id = ? ", belt.id], :order => "created_at DESC"}}
  named_scope :for_user, lambda{|teacher| {:conditions => ["user_id = ? OR tracker_id =?", teacher.id, teacher.id], :order => "created_at DESC"}}
  named_scope :since_date, lambda{|begin_date| {:conditions => ["session_date >= ? ", begin_date], :order => "session_date ASC"}}  
  named_scope :before_date, lambda{|end_date| {:conditions => ["session_date <= ? ", end_date], :order => "session_date ASC"}}  
  named_scope :between_dates, lambda{|begin_date,end_date| {:conditions => ["session_date >= ? AND session_date <= ? ", begin_date, end_date], :order => "session_date ASC"}}  


  validates_numericality_of :students, :greater_than_or_equal_to => 0, :message => 'Attendance Must Be Zero Or Greater' 
  validates_numericality_of :duration, :greater_than_or_equal_to => 60, :message => ' => Invalid Class Duration' 
  validates_presence_of :itl_template_id, :message => 'Must Select Observation Template'

  def self.destroy_sessions(school,status)
    count = 0
    if school
      if status == 'open'
        sessions = school.tlt_sessions.open
      elsif status == 'practice'
        sessions = school.tlt_sessions.practice
      else
        sessions = []
      end
      count = sessions.size
      sessions.destroy_all
    end
    count
  end
  def logs_for_activity(activity)
    self.tlt_session_logs.select{|l| l.tl_activity_type_task.tl_activity_type.id == activity.id}
  end

  def logs_for_method(method)
    self.tlt_session_logs.select{|l| l.tl_activity_type_task.tl_activity_type.app_method_id == method.id}
  end

  def logs_for_task(task)
    self.tlt_session_logs.select{|l| l.tl_activity_type_task_id == task.id}
  end

  def log_activities_for_method(method)
    self.tlt_session_logs.collect{|l| l.tl_activity_type_task.tl_activity_type}.uniq.select{|a| method.tl_activity_types.include?(a)}
  end

  def measured_time
    self.tlt_session_logs.collect{ |l| l.duration}.sum 
  end

  def session_duration(end_time)
    self.is_manual ? self.measured_time : end_time - self.created_at  
  end

  def observe_begin_time
    self.tlt_session_logs.first.start_time rescue nil  
  end

  def measured_activity_time(activity)
    self.tlt_session_logs.select{ |log| log.tl_activity_type_task.tl_activity_type == activity}.collect{ |l| l.duration}.sum 
  end

  def backlog
    self.select{|s| !s.is_pending}
  end

  def student_survey
    self.survey_schedules.for_audience(CoopApp.itl.first.tlt_survey_audiences.student.first).first rescue nil
  end

  def student_count
    self.classroom_period.nil? ? 0 : self.classroom_period.students.size
  end

  def student_survey_expired?
    instruction = SurveyInstruction.for_audience(CoopApp.itl.first.tlt_survey_audiences.student.first).for_type(CoopApp.itl.first.tlt_survey_types.observation.first).first 
    unless instruction.nil?
     self.session_date + instruction.default_days.days <= Date.today
    else 
      true    
    end
  end

  def student_involvement_for_task(task)
    scores = self.tlt_session_logs.for_task(task).collect{|l| l.involve_score}.compact
    avg = scores.empty? ? nil: scores.sum/scores.size
  end
  
  def student_survey_available?
    app = CoopApp.itl.first
    !self.organization.tlt_survey_questions.for_audience(app.tlt_survey_audiences.student.first).for_type(app.tlt_survey_types.observation.first).active.empty?
  end

  def training?
    self.is_training
  end

  def practice?
    self.is_training
  end
  
  def finalized?
    self.is_final
  end
  
  def finalizable?(user)
    if self.organization && self.organization.itl_org_option
      !self.finalized? && (self.tracker_id == user.id  || (self.user_id == user.id && self.organization.itl_org_option.is_teacher_finalize))
    else
      false 
    end
  end

  def practice_video?
    self.training? && self.tlt_session_video
  end

  def template?
    !self.itl_template_id.nil? && self.itl_template
  end

  def methods?
    !self.app_methods.empty?
  end

  def active_strategies
    self.tlt_session_logs.active.collect{|l| l.tl_activity_type_task}.uniq
  end

  def active_strategy_evidences
    self.active_strategies.collect{|s| s.evidences.enabled}.flatten.uniq rescue[]
  end

  def active_strategy_evidences_method(method)
    self.active_strategy_evidences.select{|s| s.tl_activity_type.app_method_id == method.id}
  end
  
  def irr?
    self.itl_blackbelt
  end

  def blackbelt_available?
    self.content && self.content.itl_blackbelt && (self.content.itl_blackbelt.tlt_session != self)
  end

  def irr_session
    self.content.itl_blackbelt.tlt_session rescue nil
  end


end
