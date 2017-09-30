class Classroom < ActiveRecord::Base
  include PublicPersona
    
  belongs_to :user
  scope :archived, :conditions => {:status=> "archived"}

  has_many :topics, :dependent => :destroy

  has_many :authorizations, :as => :scope, :dependent => :destroy
  has_many :authorized_users, :through => :authorizations, :source => :user, :uniq => true do
    def find_all_by_authorization_level_id(authorization_level)
      find :all, :include => :authorizations, :conditions => ["authorizations.authorization_level_id = ?", authorization_level]
    end
  end
  has_many :classroom_referrals, :dependent => :destroy
  has_many :referenced_topics, :through => :classroom_referrals, :source => :topic
  belongs_to :classroom_referral, :foreign_key => "classroom_referral_id"
  
  has_many :classroom_contents, :dependent => :destroy
  has_many :contents, :through => :classroom_contents, :order => "position"

  has_many :homeworks, :order => "classroom_id", :dependent => :destroy
  has_many :classroom_periods, :dependent => :destroy

  has_one   :total_view, :as => :entity, :dependent => :destroy
  
  belongs_to   :subject_area
  has_one   :act_subject, :through => :subject_area
  has_many :act_assessment_classrooms, :dependent => :destroy
  has_many :act_assessments, :through => :act_assessment_classrooms, :order => "position"
  has_many :act_submissions
  has_many :act_answers
  has_many :ifa_dashboards, :as => :ifa_dashboardable, :order => "period_end asc", :dependent => :destroy
  has_one  :ifa_classroom_option, :dependent => :destroy 
  has_many :ifa_question_logs
  has_many :tlt_sessions 
  has_many :tlt_dashboards
  has_many :itl_summaries 
    
  belongs_to :featured_topic, :class_name => "Topic"
  belongs_to :organization
  belongs_to :leader, :class_name => 'User', :foreign_key => "user_id"

  has_one :folder_folderable, :as => :folderable, :dependent => :destroy, :order => "position"
  has_one :folder, :through => :folder_folderable

  has_many :elt_cases 
  
  validates_presence_of :subject_area_id, :message => 'must be defined.  ' 
  validates_presence_of :course_name, :message => 'must be defined.  '
  before_destroy :confirm_no_leaders?


  scope :on_subject, lambda{|subject| {:conditions => ["subject_area_id = ? ", subject.id], :order => "course_name"}}
  scope :active, :conditions => ["status = ? ", "active"], :order => "course_name"
  scope :opened, :conditions => ["is_open = ? ", true]
  scope :closed, :conditions => ["is_open = ? ", false]
  scope :with_authorization, lambda{|user,auth| {:include => "authorizations", :conditions => ['authorizations.user_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ?', user.id, 'Classroom', auth.id], :order => 'course_name'}}

  scope :with_course_names, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
 #     condition_strings << '(course_name REGEXP ? OR course_name REGEXP ? OR topics.title REGEXP ? OR topics.title REGEXP ?)'
        condition_strings << '(course_name REGEXP ? OR course_name REGEXP ?)'
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}"
   #     conditions << "^#{keyword}"
   #     conditions << "\s+#{keyword}"
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "course_name")
    {:conditions => conditions, :include => :topics, :order => order_by}
  }
  

  scope :with_subject_areas, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(subject_areas.name LIKE ?)'
      conditions << "%#{keyword}%"
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "subject_areas.name")
    {:conditions => conditions, :include => :subject_area, :order => order_by}
  }
  
    scope :with_organizations, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(organizations.name LIKE ?)'
      conditions << "%#{keyword}%"
    end
    condition_string = condition_strings.join(" OR ")
    conditions.unshift condition_string
    order_by = (options[:order] || "course_name")
    {:conditions => conditions, :include => :organization, :order => order_by}
  }

   
  def increment_views
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.increment
  end
  
  def views
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.views
  end 
 
  def first_view_date
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.created_at
  end
  
  def last_view_date
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.updated_at
  end
   
  def self.new_registration_key(length = 8)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    password = ""
    1.upto(length) { |i| password << chars[rand(chars.size-1)] }
    password
  end

  def name
    self.course_name
  end

  def precision_prep?
    self.is_prep
  end

  def self.for_subject(subject)
    where('act_subject_id = ?', subject.id)
  end

  def self.precision_prep
    where('status = ? && is_prep', 'active')
  end

  def self.all_precision_prep
    where('is_prep')
  end

  def self.precision_prep_provider(provider)
    where('is_prep').select{|c| c.organization.app_provider(CoopApp.ifa) == provider}
  end

  def self.precision_prep_subject(subject)
    where('act_subject_id = ? && status = ? && is_prep', subject.id, 'active')
  end

  def ifa_enable
    if self.organization.ifa_enabled?
      ifa_option = IfaClassroomOption.new
      ifa_option.is_ifa_notify = true
      ifa_option.is_ifa_auto_finalize = false
      ifa_option.act_subject_id = self.act_subject_id
      ifa_option.act_master_id =  nil
      ifa_option.is_calibrated = false
      ifa_option.is_user_filtered = false
    #  ifa_option.days_til_repeat = self.organization.ifa_org_option.days_til_repeat
      ifa_option.days_til_repeat = 0
      ifa_option.classroom_id = self.id
      ifa_option.save
    end
  end

  def ifa_enabled?
    (self.ifa_classroom_option && self.organization.ifa_enabled? && self.act_subject) ? true : false
  end

  def last_ifa_dashboard(subject)
    self.ifa_dashboards.for_subject(subject).empty? ? nil :
        self.ifa_dashboards.for_subject(subject).first
  end

  def ifa_subject
    self.subject_area.act_subject rescue nil
  end
  def act_subject
    self.subject_area.act_subject rescue nil
  end

  def ifa_plannable?
    self.ifa_enabled? && self.organization.ifa_plannable?
  end

  def ifa_disable
      self.ifa_classroom_option.destroy rescue nil
  end

  def ifa_notify?
    self.ifa_classroom_option ? self.ifa_classroom_option.is_ifa_notify : false
  end

  def ifa_auto_finalize?
    self.ifa_classroom_option ? self.ifa_classroom_option.is_ifa_auto_finalize : false
  end

  def ifa_retake_days
    self.ifa_classroom_option ? (self.ifa_classroom_option.days_til_repeat == nil ? 0 : self.ifa_classroom_option.days_til_repeat) : 0
  end

  def available_assessments
    self.act_assessments.active.sort_by{|a| a.lower_level.lower_score}
  end

  def active?
      self.status == "active"
  end
    
  def open?
      self.is_open
  end
  def not_open?
    !self.is_open
  end
  def self.all_open?(offerings)
    offerings.select{|o| o.not_open?}.empty?
  end

  def active_for?(user)
      self.active? && user
  end
  
  def viewable_by?(user)
    self.open? || (user && (user.student_of_classroom?(self) || user.teacher_of_classroom?(self)))
  end

  def joinable_by?(user)
    (user && !user.student_of_classroom?(self) && !user.teacher_of_classroom?(self) && !self.classroom_periods.empty?)
  end



  def sequence_resources
  resources = self.classroom_contents.sort_by{|cc|cc.position}
  resources.each_with_index do |rsrc,idx|
    rsrc.update_attributes(:position=>idx+1)
    end
  end   

   def reference_topics
#   self.authorizations.colleague.collect{|a| a.scope}
     topics = self.classroom_referrals
     topic_list = []
     topics.each do |tpc|
     topic_list << Topic.first.where('id= ?', tpc.topic_id)
    end
    topic_list
  end 
#
#   Classroom Period 
# 

  def with_tlt_sessions
    !self.tlt_sessions.empty?
  end

  def self.precision_prep_students
    where('status = ? && is_prep', 'active').collect{|c| c.students}.flatten.uniq
  end
 
  def students
    self.classroom_periods.collect{|cp| cp.students}.compact.flatten.uniq
  end

  def teachers
    self.classroom_periods.collect{|cp| cp.classroom_period_users.teachers}.flatten.collect{|u| u.user}.compact.uniq
  end

  def users
    self.classroom_periods.collect{|cp| cp.classroom_period_users}.flatten.collect{|u| u.user}.compact.uniq
  end  
  def all_users
    self.classroom_periods.collect{|cp| cp.users}.flatten.compact.uniq
  end 
  def students_of_teacher(teacher)
    self.periods_for_user(teacher).collect{|cp| cp.classroom_period_users.students}.flatten.collect{|u| u.user}.compact.uniq
  end  
  def teachers_for_student(student)
    self.period_for_student(student).teachers rescue []
  end
  def period_for_student(student)
    self.classroom_periods.select{|p| p.users.include?(student)}.first rescue nil
  end
  def student_period(student)
    self.classroom_periods.select{|p| p.classroom_period_users.students.collect{|s| s.user_id}.include?(student.id)}.first rescue nil
  end
  def teacher_periods(teacher)
    self.classroom_periods.select{|p| p.classroom_period_users.teachers.collect{|s| s.user_id}.include?(teacher.id)} rescue []
  end

  def learning_units
    self.topics.sort_by{|lu| lu.estimated_start_date}
  end

  def periods_for_user(user)
    self.classroom_periods.select{|p| p.users.include?(user)} rescue nil
  end
  def teacher_list
    unless self.teachers.empty?
      self.teachers.collect{|t| t.last_name}.uniq.join(", ")
    else
      ""
    end
  end

  def parent_subject
    unless self.subject_area.parent_id.nil?
      self.subject_area.parent
    else
      self.subject_area
    end
  end

  def for_subject?(subject)
    (self.subject_area && (self.subject_area == subject || self.subject_area.parent_subject == subject)) ? true : false
  end

  def homework_enabled?
    self.homework_option
  end

  def homeworks_for_teacher(user)
    self.homeworks.for_teacher(user)
  end

  
  def observers
     clssrm_auths = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Classroom', AuthorizationLevel.favorite, self)
     obs = []
     clssrm_auths.each do |ob|
     obs << User.where('id= ?', ob.user_id).first
    end
    obs
  end 
 
  def leaders
    self.teachers
  end

  def participants
    self.students.sort{|a,b| a.last_name <=> b.last_name}
  end

  def leaders_and_students
    (self.teachers + self.students).compact.uniq
  end

#
#  Resources Of Others Used in Classroom
#
  def otr
    tot_resources = self.resources.uniq rescue []
     if tot_resources.size > 0
       teachers = self.teachers
       teachers.each do |t|
         tot_resources = tot_resources - t.contents.active
       end
   end
   tot_resources
 end 

#
#  Average Student Mastery Level
#
  def cml(start_date, end_date, current_standard)
    answer_list = self.act_answers.selected.select{|ans| ans.created_at >= start_date && ans.created_at <= end_date}
    sms_level = current_standard.sms(answer_list, self.act_subject_id, 0,0, self.organization.id)
  end

  def resources
    resource_list = self.contents.flatten.uniq
    resource_list += self.topics.collect{|tpc| tpc.contents}.flatten.uniq
    resource_list.uniq
  end

  def discussion_comments
    comment_list = self.topics.collect{|tpc| tpc.discussions}.flatten
  end

  def duplicate_contents(offering)
    offering.classroom_contents.each do |content|
      dup_content = ClassroomContent.new
      dup_content = content.dup
      self.classroom_contents << dup_content
    end
  end

  def duplicate_referrals(offering)
    offering.classroom_referrals.each do |referral|
      dup_referral = ClassroomReferral.new
      dup_referral = referral.dup
      self.classroom_referrals << dup_referral
    end
  end

  def duplicate_ifa(offering)
    if offering.ifa_classroom_option
      ifa_option = IfaClassroomOption.new
      ifa_option = offering.ifa_classroom_option.dup
      self.ifa_classroom_option = ifa_option
    end
    offering.act_assessment_classrooms.each do |ass|
      dup_ass = ActAssessmentClassroom.new
      dup_ass = ass.dup
      self.act_assessment_classrooms << dup_ass
    end
  end

  def duplicate_periods(offering)
    offering.classroom_periods.each do |orig_per|
      new_per = orig_per.dup
      self.classroom_periods << new_per
    end
  end

  def duplicate_lus(offering)
    offering.topics.each do |orig_lu|
      new_lu = orig_lu.dup
      new_lu.user_id = self.user_id
      new_lu.last_posted_at = nil
      self.topics << new_lu
      if offering.featured_topic == orig_lu
        self.update_attributes(:featured_topic_id => new_lu.id)
      end
      new_lu.duplicate_contents(orig_lu)
      new_lu.duplicate_ifa(orig_lu)
      new_lu.duplicate_lu_folders(orig_lu)
    end
  end

  def folders_with_mastery(mastery)
    self.topics.map{|t| t.folders}.flatten.uniq.select{|f| f.mastery_levels.include?(mastery)}
  end

  private

  def confirm_no_leaders?
    self.leaders.empty?
  end


end
