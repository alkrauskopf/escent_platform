class Classroom < ActiveRecord::Base
  include PublicPersona
    
  named_scope :active, :conditions => {:status=> "active"}
  named_scope :archived, :conditions => {:status=> "archived"}

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
  belongs_to   :act_subject
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
  
  named_scope :on_subject, lambda{|subject| {:conditions => ["subject_area_id = ? ", subject.id], :order => "course_name"}}
  named_scope :active, :conditions => ["status = ? ", "active"], :order => "course_name"
  named_scope :open, :conditions => ["is_open = ? ", true]
  named_scope :closed, :conditions => ["is_open = ? ", false]
 
  named_scope :with_course_names, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(course_name REGEXP ? OR course_name REGEXP ? OR topics.title REGEXP ? OR topics.title REGEXP ?)'
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}"
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}" 
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "course_name")
    {:conditions => conditions, :include => :topics, :order => order_by}
  }
  

  named_scope :with_subject_areas, lambda { |keywords, options|
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
  
    named_scope :with_organizations, lambda { |keywords, options|
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
 
  def ifa_enable
      if self.organization.ifa_org_option
        ifa_option = IfaClassroomOption.new
        ifa_option.is_ifa_notify = true
        ifa_option.is_ifa_auto_finalize = false
        ifa_option.act_subject_id = self.act_subject_id
        ifa_option.act_master_id = ActMaster.first.id
        ifa_option.is_calibrated = false
        ifa_option.is_user_filtered = false
        ifa_option.days_til_repeat = self.organization.ifa_org_option.days_til_repeat
        self.ifa_classroom_option = ifa_option
      end
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
    
  def active?
      self.status == "active"
  end
    
  def open?
      self.is_open
  end
  
  def active_for?(user)
      self.active? && user
  end
  
  def viewable_by?(user)
    self.open? || (user && (user.student_of_classroom?(self) || user.teacher_of_classroom?(self)))
  end


  def sequence_resources
  resources = self.classroom_contents.sort_by{|cc|cc.position}
  resources.each_with_index do |rsrc,idx|
    rsrc.update_attributes(:position=>idx+1)
    end
  end   

   def reference_topics
#   self.authorizations.colleague.collect{|a| a.scope}
     topics = ClassroomReferral.find(:all, :conditions => ["classroom_id = ? ", self.id])
     topic_list = []
     topics.each do |tpc|
     topic_list << Topic.find(:first, :conditions => ["id= ?", tpc.topic_id])
    end
    topic_list
  end 
#
#   Classroom Period 
# 

  def with_tlt_sessions
    !self.tlt_sessions.empty?
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

  def homework_enabled?
    self.homework_option
  end

  def homeworks_for_teacher(user)
    self.homeworks.for_teacher(user)
  end

  
  def observers
#    self.authorizations.colleague.collect{|a| a.scope}
     clssrm_auths = Authorization.find(:all, :conditions => ["scope_type = ? AND authorization_level_id = ? AND scope_id = ?", "Classroom", AuthorizationLevel.favorite, self])
     obs = []
     clssrm_auths.each do |ob|
     obs << User.find(:first, :conditions => ["id= ?", ob.user_id])
    end
    obs
  end 
 
  def leaders
    self.teachers
  end  
  def leaders_old
#    self.authorizations.colleague.collect{|a| a.scope}
     clssrm_auths = Authorization.find(:all, :conditions => ["scope_type = ? AND authorization_level_id = ? AND scope_id = ?", "Classroom", AuthorizationLevel.leader, self])
     ldrs = []
     clssrm_auths.each do |l|
     ldrs << User.find(:first, :conditions => ["id= ?", l.user_id])
    end
    ldrs
  end   

  def participants
    self.students
  end

  
  def participants_old
#    self.authorizations.colleague.collect{|a| a.scope}
     clssrm_auths = Authorization.find(:all, :conditions => ["scope_type = ? AND authorization_level_id = ? AND scope_id = ?", "Classroom", AuthorizationLevel.participant, self])
     prts = []
     clssrm_auths.each do |l|
     prts << User.find(:first, :conditions => ["id= ?", l.user_id])
    end
    prts
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
 
  def reference_name
    "#{organization.name} - #{course_name} (#{self.leader.last_name})"
  end
end
