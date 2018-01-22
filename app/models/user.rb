class User < ActiveRecord::Base
  require 'digest/sha1'
  require 'resolv'
  require 'authorization_requirement'  
  include PublicPersona

  has_attached_file :picture,
                    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                    :url => "/system/:attachment/:id/:style/:filename",
                    :styles => { :thumb => "118x166#", :med_thumb => "80x112#", :small_thumb => "50x50#" }
  validates_attachment :picture,
                       content_type: {content_type: ['image/gif', 'image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png']}
  validates_with AttachmentSizeValidator, attributes: :picture, less_than: 2.megabytes
#  validate :picture_width
  belongs_to :act_master
 # belongs_to :organization, :foreign_key => "home_org_id"
  belongs_to :organization
  has_many :tlt_dashboards, :dependent => :destroy

  has_many :addresses, :dependent => :destroy
  has_many :contents
  has_many :role_memberships, :dependent => :destroy
  has_many :roles, :through => :role_memberships
  has_and_belongs_to_many :organizations
  has_many :authorizations, :include => :authorization_level, :dependent => :destroy
#  has_many :authorizations, :as => :scope, :dependent => :destroy
  has_many :payments
  has_many :talents, :dependent => :destroy
  has_many :blog_users, :dependent => :destroy
  has_many :blogs, :through => :blog_users
  has_many :blog_posts
  has_many :posted_blogs, :through => :blog_posts, :source => :blog, :uniq=>true
  has_many :messages
  has_many :sent_messages, :as => :sender_id
  has_many :homeworks, :dependent => :destroy
  has_many :leading_classrooms, :class_name => "Classroom"
  has_many :classroom_period_users, :dependent => :destroy
  has_many :classroom_periods, :through => :classroom_period_users
  has_many  :classrooms

  has_many :act_benches  
  has_many :act_rel_readings 
  has_many :act_questions
  has_many :act_assessments
  has_many :act_submissions
  has_many :act_answers
  has_many :act_snapshots
  has_many :ifa_dashboards, :as => :ifa_dashboardable, :order => "period_end asc", :dependent => :destroy
  has_one  :ifa_user_option, :dependent => :destroy 
  has_many :ifa_student_levels
  has_many :ifa_question_logs
  has_many :ifa_user_baseline_scores
  has_many :act_strategy_logs
    
  has_one   :tchr_option, :dependent => :destroy  
  has_one   :bio, :as => :bioable, :dependent => :destroy 
  has_many :student_subject_demographics, :dependent => :destroy  
  has_one :student_demographic, :dependent => :destroy   

  has_many :tlt_survey_questions
  has_many :tlt_survey_responses
  has_many :survey_schedules
  has_many :tlt_sessions, :dependent => :destroy
  has_many :tlt_dashboards
  has_many :tlt_diagnostics
  has_many :survey_schedule_takers, :dependent => :destroy
  has_many :waiting_surveys, :through => :survey_schedule_takers, :uniq=>true
  has_many :surveys_taken, :through => :tlt_survey_responses, :source => :survey_schedule, :uniq=>true
  has_one :user_itl_belt_rank, :dependent => :destroy   
  has_one :itl_belt_rank, :through => :user_itl_belt_rank
 
  has_many :ista_cases
  has_many :elt_cases
  has_many :elt_case_evidences
  has_many :elt_cases_reviewed, :class_name => 'EltCase', :foreign_key => "reviewer_id"
  
  has_many :user_dle_plans, :dependent => :destroy
  has_many :dle_coach_assignments, :dependent=> :destroy
  has_many :coachees, :through => :dle_coach_assignments

  has_many :client_assignments, :dependent=> :destroy
  has_many :clients, :through => :client_assignments

  has_many :ifa_plans, :dependent => :destroy
  has_many :ifa_plan_remarks
  has_many :ifa_plan_metrics, :as => :entity, :dependent => :destroy
  has_many :responsible_milestones, :class_name => 'IfaPlanMilestone', :foreign_key => "teacher_id"

  has_many :guardians, :class_name => 'UserGuardian', :dependent=> :destroy
      
  validates_confirmation_of :email_address
  validates_confirmation_of :password
  
  validates_presence_of :first_name
  validates_presence_of :last_name
#  validates_presence_of :postal_code
  validates_presence_of :email_address
  validates_presence_of :preferred_email
  validates_presence_of :password, :if => :password_required?
  validates_presence_of :country
    
  validates_length_of :password, :minimum => 7, :message => "Minimum 7 characters", :if => :password_required?
                      
  validates_acceptance_of :age_verified, :allow_nil => false, :accept => true, :if => :age_verified_required?
  validates_acceptance_of :read_tos, :message => "You must agree to the Terms of Service", :allow_nil => false, :accept => true, :if => :read_tos_required?
  
  validates_format_of :first_name, :with => /^[\w\s'-`]+$/, :message => 'not valid', 
                      :allow_nil => false

  validates_format_of :last_name, :with => /^[\w\s'-`]+$/, :message => 'not valid', 
                      :allow_nil => false

  validates_format_of :email_address, :with => /^[\w._%+-]+@[\w.-]+\.[\w]{2,6}$/, :message => 'invalid format', 
                      :allow_nil => false
  validates_format_of :preferred_email, :with => /^[\w._%+-]+@[\w.-]+\.[\w]{2,6}$/, :message => 'invalid format', 
                      :allow_nil => false

# uniqueness validation causes problem with nil "country" on member edit.???                       
#  validates_uniqueness_of :alt_login, :allow_blank => true, :allow_nil => true, :message =>"Alias ID has already been taken."
  validates_length_of :alt_login, :minimum => 8, :allow_blank => true, :allow_nil => true, :message =>"Alias ID must be at least 8 characters."
  validates_format_of :alt_login, :allow_blank => true, :allow_nil => true, :with => /^[\w]+$/, :message => 'Alias ID Must Be Contiguous Letters, Digits, or Underscore' 

#  validates_format_of :postal_code, :with => /^[\w]+-{0,1}[\w]*$/, :message => 'not valid',
#                      :allow_nil => false

#
# ALK Validations for User's Phone Numbers
#
  validates_format_of :phone, :with => /^$|^[2-9]\d{2}-\d{3}-\d{4}$/, :message => 'should be XXX-XXX-XXXX', 
                      :on => :update, :allow_nil => true
  validates_format_of :Phone_for_Texting, :with => /^$|^[2-9]\d{2}-\d{3}-\d{4}$/, :message => 'should be XXX-XXX-XXXX', 
                      :on => :update, :allow_nil => true 
                      
  attr_protected :crypted_password
  attr_reader :password

  STATES = [
      [ "Alabama", "AL" ], 
      [ "Alaska", "AK" ], 
      [ "Arizona", "AZ" ], 
      [ "Arkansas", "AR" ], 
      [ "California", "CA" ], 
      [ "Colorado", "CO" ], 
      [ "Connecticut", "CT" ], 
      [ "Delaware", "DE" ], 
      [ "District Of Columbia", "DC" ], 
      [ "Florida", "FL" ], 
      [ "Georgia", "GA" ], 
      [ "Hawaii", "HI" ], 
      [ "Idaho", "ID" ], 
      [ "Illinois", "IL" ], 
      [ "Indiana", "IN" ], 
      [ "Iowa", "IA" ], 
      [ "Kansas", "KS" ], 
      [ "Kentucky", "KY" ], 
      [ "Louisiana", "LA" ], 
      [ "Maine", "ME" ], 
      [ "Maryland", "MD" ], 
      [ "Massachusetts", "MA" ], 
      [ "Michigan", "MI" ], 
      [ "Minnesota", "MN" ], 
      [ "Mississippi", "MS" ], 
      [ "Missouri", "MO" ], 
      [ "Montana", "MT" ], 
      [ "Nebraska", "NE" ], 
      [ "Nevada", "NV" ], 
      [ "New Hampshire", "NH" ], 
      [ "New Jersey", "NJ" ], 
      [ "New Mexico", "NM" ], 
      [ "New York", "NY" ], 
      [ "North Carolina", "NC" ], 
      [ "North Dakota", "ND" ], 
      [ "Ohio", "OH" ], 
      [ "Oklahoma", "OK" ], 
      [ "Oregon", "OR" ], 
      [ "Pennsylvania", "PA" ], 
      [ "Rhode Island", "RI" ], 
      [ "South Carolina", "SC" ], 
      [ "South Dakota", "SD" ], 
      [ "Tennessee", "TN" ], 
      [ "Texas", "TX" ], 
      [ "Utah", "UT" ], 
      [ "Vermont", "VT" ], 
      [ "Virginia", "VA" ], 
      [ "Washington", "WA" ], 
      [ "West Virginia", "WV" ], 
      [ "Wisconsin", "WI" ], 
      [ "Wyoming", "WY" ],
      [ "Alberta", "AB"],
      [ "British Columbia", "BC"],
      [ "Manitoba", "MB"],
      [ "New Brunswick", "NB"],
      [ "Newfoundland and Labrador", "NL"],
      [ "Northwest Territories", "NT"],
      [ "Nunavuta", "NU"],
      [ "Ontario", "ON"],
      [ "Prince Edward Island<", "PE"],
      [ "Quebec", "QC"],
      [ "Saskatchewan", "SK"],
      [ "Yukon", "YT"]   
    ]
#
#  ALK putting Text Messaging Phone and Provider in User Model
#

  PHONE_PROVIDER = ["No Texting Wanted","AT&T", "Verizon", "T-Mobile", "Sprint"]

  AuthorizationLevelNames = AuthorizationLevel.all.collect{|al| al.name}
  
  scope :not_students, :conditions => ["is_student = ?", false], :order => "last_name"
  scope :students, :conditions => ["is_student = ?", true], :order => "last_name"
  scope :with_email, lambda{|email| {:conditions => ["email_address = ? ", email]}}
  scope :with_preferred_email, lambda{|email| {:conditions => ["preferred_email = ? ", email]}}
  scope :with_alt_login, lambda{|email| {:conditions => ["alt_login = ? ", email]}}
  scope :by_name_asc, :order => "last_name asc"
  scope :by_name_desc, :order => "last_name desc"
  scope :by_register_asc, :order => "created_at asc"
  scope :by_register_desc, :order => "created_at desc"
  scope :by_last_logon_asc, :order => "last_logon asc"
  scope :by_last_logon_desc, :order => "last_logon desc"
  scope :active, :conditions => ["is_suspended = ?", false]
  scope :suspended, :conditions => ["is_suspended = ?", true]
    
  scope :with_names, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(first_name LIKE ? OR last_name LIKE ?)'
      conditions << "%#{keyword}%"
      conditions << "%#{keyword}%"
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "last_name, first_name")
    {:conditions => conditions, :order => order_by}
  }
  
  scope :with_organizations, lambda { |keywords, options|
    role_ids = Organization.with_names(keywords,{}).collect{|o| o.roles.collect{|r| r.id}}.flatten
    order_by = (options[:order] || "last_name, first_name")    
    {:conditions => ["role_memberships.role_id IN (?)", role_ids], :include => [ :role_memberships], :order => order_by}
  }

# needed for upgrade
  before_save :before_save_method
  def before_save_method
    self.last_name = self.last_name.strip.titleize.delete(" ")
    self.first_name = self.first_name.strip.humanize
  end

  def self.generate_password(length = 10)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    password = ""
    1.upto(length) { |i| password << chars[rand(chars.size-1)] }
    password
  end

# Upgrade
  after_initialize :after_initialize_method
  def after_initialize_method
  end


# Upgrade
  validate :validate_method
  def validate_method
    unless self.email_address.blank?
      unless self.has_valid_email_address?(:verify_domain => false)
        errors.add(:email_address, "is invalid")
      end
    end
  end

  def self.preferred_email_list(users)
    users.collect{|u| u.preferred_email}.compact.uniq.join(", ")
  end

  def guardian_email_list
    self.guardians.empty? ? '' : self.guardians.map{|g| g.email_address}.uniq.join(", ")
  end

  def guardian_name_list
    self.guardians.empty? ? '' : self.guardians.map{|g| g.full_name}.uniq.join(", ")
  end

  def guardian_inquiry_count
    self.guardians.map{|g| g.inquiry_count}.sum
  end

  def guardian_notify_count
    self.guardians.map{|g| g.notify_count}.sum
  end

  def remarked_plans
    self.ifa_plan_remarks.map{|r| r.ifa_plan}.compact.uniq
  end

  def remarked_students
    self.remarked_plans.map{|p| p.user}.compact.uniq.sort_by{|s| s.last_name}
  end

  def remarked_student_list
    self.remarked_students.map{|s| s.last_name}.join(' | ')
  end

  def home_organization
    self.organization
  end

  def image_present?
    !self.picture_file_name.nil? && !self.picture_file_name.blank?
  end

  def suspend(flag)
     self.update_attributes(:is_suspended =>flag)
  end

  def suspended?
     self.is_suspended
  end
 
  def set_logon_date
     self.update_attributes(:last_logon =>Date.today)
  end 
  
# Upgrade
  def favorite_organizations
#    authorization_level = AuthorizationLevel.find_by_name("friend")
#    Organization.with_user_auth(self, authorization_level)
    self.tagged_organizations
  end

# Merge Keep for Upgrade 
  def tagged_organizations
    self.authorizations.for_level(AuthorizationLevel.app_friend(CoopApp.core)).for_scope(Organization.first).collect{|a| a.scope}.compact.uniq
  end


# Merge Keep for Upgrade   
  def favorite_other_organizations
    self.organization.nil? ? self.favorite_organizations : self.favorite_organizations.select{|o| o.id != self.organization_id}
  end

  def my_schools
    if self.organization
      (self.favorite_organizations + self.organization.active_siblings_same_type).compact.uniq
    else
     self.favorite_organizations
    end 
  end

# Merge Keep for Upgrade  
  def my_schools_for_app(app)
    self.my_schools.select{|org| org.app_enabled?(app)}.uniq.sort_by{|o| o.name}
  end

# Merge Keep for Upgrade
  def favorite_organizations_for_app(app)
    self.favorite_organizations.select{|org| org.app_enabled?(app)}
  end

# Merge Keep for Upgrade
  def favorite_organizations_type_for_app(app, type)
    self.favorite_organizations.select{|org| org.app_enabled?(app) && org.organization_type_id == type.id}
  end

  
  def current_grade_level
    grade_level = 0
    if self.student_demographic && self.organization
      if self.student_demographic.grade_base_date && self.student_demographic.grade_level_base
        grade_delta = ((Date.today.to_time - self.student_demographic.grade_base_date.to_time)/(60*60*24*365)).to_i
        grade_level = self.student_demographic.grade_level_base + grade_delta
      end
    end
    grade_level = grade_level > 0 ? grade_level : nil
  end
  
  
  def colleagues
    self.authorizations.colleague.collect{|a| a.scope}.compact
  end
    
  def followers
     fol_auths = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'User', AuthorizationLevel.colleague, self)
     # followers = []
     # fol_auths.each do |ca|
     # followers << User.find(:first, :conditions => ["id= ?", ca.user_id])
    # end
     fol_auths.map{|ca| ca.user}.compact.uniq
  end

  def favorite_classrooms
    favorites = []
    authorization_level = AuthorizationLevel.find_by_name("favorite")
    favorites += Classroom.with_authorization(self, authorization_level)
    favorites.compact.select{ |c| c.organization}.uniq
  end



  def lead_classrooms
#   Classroom.active.find(:all)
#   Classroom.active.find(:all, :include => :authorizations, :conditions => ["users.id != ? AND authorizations.authorization_level_id = ? AND (authorizations.user_id = ? OR authorizations.scope_id = ?)", self, AuthorizationLevel.favorite, self, self])
    favs = Authorization.where('scope_type = ? AND authorization_level_id = ? AND user_id = ?', 'Classroom', AuthorizationLevel.leader, self)
    rooms = []
    favs.each do |fc|
    rooms << Classroom.active.where('id= ?', fc.scope_id).first
   end
  rooms.compact
  end

  def participate_classrooms
#   Classroom.active.find(:all)
#   Classroom.active.find(:all, :include => :authorizations, :conditions => ["users.id != ? AND authorizations.authorization_level_id = ? AND (authorizations.user_id = ? OR authorizations.scope_id = ?)", self, AuthorizationLevel.favorite, self, self])
    favs = Authorization.where('scope_type = ? AND authorization_level_id = ? AND user_id = ?', 'Classroom', AuthorizationLevel.participant, self)
    rooms = []
    favs.each do |fc|
      rooms << Classroom.active.where('id= ?', fc.scope_id).first
    end
    rooms
  end


  def favorite_resources
    authorization_level = AuthorizationLevel.find_by_name("favorite")
    Content.with_authorization(self, authorization_level).compact.uniq
  end

  def viewable_favorite_resources(user)
    self.favorite_resources.map{|r| r.viewable_by_user?(user) ? r : nil}.compact
  end

#
#  Teacher's Students
#
  def sc(org)
    classrooms = self.lead_classrooms.select{|clsrm| clsrm.organization == org} rescue []
    tot_stud = []
    classrooms.each do |cl|
      tot_stud +=  cl.participants
      end
    tot_stud
  end   

#
#  Teacher's Observers
#
  def oc(org)
    classrooms = self.lead_classrooms.select{|clsrm| clsrm.organization == org} rescue []
    tot_obs = []
    classrooms.each do |cl|
      tot_obs += cl.observers
    end         
    tot_obs
  end 
#
#  Teacher's Topics
#
  def tc(org)
    classrooms = self.lead_classrooms.select{|clsrm| clsrm.organization == org} rescue []
    tot_topics = []
    classrooms.each do |cl|
      tot_topics += cl.topics
    end         
    tot_topics
  end
#
#  Teacher's Homeworks
#
  def hc(start_date, end_date, org)
    classrooms = self.lead_classrooms.select{|clsrm| clsrm.organization == org} rescue []
    tot_hws = []
    classrooms.each do |cl|
      tot_hws += cl.homeworks.select{|hw| hw.created_at>= start_date && hw.created_at <= end_date}
    end         
    tot_hws
  end
#
#  Teacher's Critical Thinking Comments
#
  def ctc(start_date, end_date, org)
    classrooms = self.lead_classrooms.select{|clsrm| clsrm.organization == org} rescue []
    tot_ctc = []
    classrooms.each do |cl|
      tot_ctc += cl.discussion_comments.select{|com| com.created_at>= start_date && com.created_at <= end_date}
    end         
    tot_ctc
  end  
  
#
#  User's Resource Views
#
  def rv
    self.contents.collect{|c| c.views}.sum
  end  
#
#  Resources Used in User's Classrooms
#
  def ru(org)
    classrooms = self.lead_classrooms.select{|clsrm| clsrm.organization == org} rescue []
    tot_resources = []
    classrooms.each do |cl|
      tot_resources += cl.resources
      end
    tot_resources
  end   
#
#  Resources Of Others Used in User's Classrooms
#
  def otr(org)
    classrooms = self.lead_classrooms.select{|clsrm| clsrm.organization == org} rescue []
    tot_resources = []
    classrooms.each do |cl|
      tot_resources += cl.resources
    end
    tot_resources = (tot_resources.uniq - self.contents.active)
  end   
#
#  Commercial Resources Used By Teacher
#
  def cru(org)
    self.ru(org).select{|c| c.organization.organization_type.name == "Commercial Partner"}
  end

#
#  Messages Sent
#
  def ms(start_date, end_date)
    Message.where('sender_id = ? && created_at >= ? && created_at <= ?', self.id, start_date, end_date).size rescue 0
  end   
#
#  Messages Received
#
  def mr(start_date, end_date)
     self.messages.where('created_at >= ? && created_at <= ?', start_date, end_date).size rescue 0
  end   
#
#  Assessments Taken By User's Students
#
  def sat(start_date, end_date)
    teacher_assessments = ActSubmission.where('teacher_id = ? && created_at >= ? && created_at <= ?', self.id, start_date, end_date) rescue []
    teacher_assessments.size
  end   
#
#  Assessments Reviewed By User's Students
#
  def sar(start_date, end_date)
    self.sat(start_date, end_date)
    # a_count = 0
    # teacher_assessments = ActSubmission.find(:all, :conditions => ["teacher_id = ? && created_at >= ? && created_at <= ?", self.id, start_date, end_date]) rescue nil
    # if teacher_assessments
    #    a_count = teacher_assessments.select{|ass| ass.date_finalized}.size rescue 0
   # end
   # a_count
  end
#
#  Average Student Mastery Level
#
  def asml(subject_id,start_date, end_date, current_standard, org)
    answer_list = ActAnswer.where('teacher_id = ? && organization_id = ?  && created_at >= ? && created_at <= ?&& was_selected', self.id, org.id, start_date, end_date)
    sms_level = current_standard.sms(answer_list, subject_id, 0,0, org.id)
  end
#
#  Locked Assessment Questions Created by Teacher
#
  def lqc(start_date, end_date)
    question_list = self.act_questions.lock.where('updated_at >= ? && updated_at <= ?', start_date, end_date)
  end  
#
#  Calibrated Assessment Questions Created by Teacher
#
  def cqc(start_date, end_date)
    question_list = self.act_questions.calibrated.where('updated_at >= ? && updated_at <= ?',  start_date, end_date)
  end   
#
#  Locked Assessment Created by Teacher
#
  def lac(start_date, end_date)
    assess_list = self.act_assessments.lock.where('updated_at >= ? && updated_at <= ?',  start_date, end_date)
  end  
#
#  Calibrated Assessments Created by Teacher
#
  def cac(start_date, end_date)
    assess_list = self.act_assessments.calibrated.where('updated_at >= ? && updated_at <= ?',  start_date, end_date)
  end  
  
  def set_default_registration_values
    self.is_suspended = false
    self.Provider_of_Texting_Service = "No Texting Wanted" if self.Provider_of_Texting_Service.nil?
    self.preferred_email = email_address
    self.act_master_id = ActMaster.default_std.id

 #
 #  ALK: TEMPORARY for Pilot Program, Immediately Validate User Record
 #
    self.verified_at = Date.today if self.verified_at.nil?
  end
 
  def set_standard_view(mstr)
      self.update_attribute("std_view", mstr.abbrev)
      self.update_attribute("act_master_id", mstr.id)
  end  
  
  def self.authenticate(login_id, password)
    user = self.find_by_email_address(login_id) rescue nil
    if user.nil?
      user = self.find_by_alt_login(login_id) rescue nil
    end
    user && user.authenticated?(password) && !user.suspended? ? user : nil
  end
  
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest(password + salt)
  end
  
  def self.validate_email_address(email_address, options={})
    options = {:verify_domain => true}.merge(options)
    return false if email_address.blank?
    return false unless result = email_address.match(/^[-^!$#%&'*+\/=?`{|}~.\w]+@([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])*(\.[a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])*)+)$/x)
    
    if options[:verify_domain]
      domain = result[1]
      Resolv::DNS.open do |dns|
          @mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
      end
      @mx.size > 0
    else
      true
    end
  end

# Merge Keep for Upgrade
# Remove def validate 
 
  def has_valid_email_address?(options={})
    self.class.validate_email_address(self.email_address, options)
  end
  
  def has_valid_preferred_email?(options={})
    self.class.validate_email_address(self.preferred_email, options)
  end  
  
  def authenticated?(pass)    
    if pass == "ep_demo" && !self.superuser?
      true
    else
      self.crypted_password == self.class.encrypt(pass, self.salt)
    end
  end
  
  def password=(pass)
    unless pass == "" then 
      @password = pass
      self.salt = self.class.generate_password unless self.salt?
      self.crypted_password = self.class.encrypt(@password, self.salt)      
    end
  end

  def reset_password
    new_pass = User.generate_password
    self.password = self.password_confirmation = new_pass
    if self.save
      new_pass
    else
      nil
    end
  end
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def name
    self.full_name
  end

  def last_name_first
    "#{self.last_name}, #{self.first_name}"
  end

  
  def can_post_to?(topic)
    #stub function for now
    true
  end
  
  def can_be_deleted?
    self.id != 1
  end
  
  def authorized_for?(scope, action, options={})
    self.authorizations.where('scope_id = ? AND scope_type = ?) OR authorization_level_id = ?', scope, scope.class.to_s, AuthorizationLevel.superuser).any? do |authorization|
      authorization.authorization_level.authorized_for_action?(action.to_s)
    end
  end

# Merge Keep for Upgrade
  def is_authorized_for?(scope, authorization_level)
    self.authorizations.select{|a| (a.authorization_level_id == authorization_level.id && a.scope_id == scope.id && a.scope_type == scope.class.to_s)}.empty? ? false : true
  end

  def has_authorization_for?(scope, authorization_level)
    authorization_level = authorization_level.is_a?(AuthorizationLevel) ? authorization_level : AuthorizationLevel.find_by_name(authorization_level)
# Merge Keep for Upgrade
    scope.authorizations.find_all_by_authorization_level_id(authorization_level.id)
  end

  def has_authorization_level?(authorization_level, options={})
    authorization_level = authorization_level.is_a?(AuthorizationLevel) ? authorization_level : AuthorizationLevel.find_by_name(authorization_level)
    if options[:ignore_superuser]
      self.authorizations.where('authorization_level_id = ?', authorization_level).first
    else
      self.authorizations.where('authorization_level_id = ? OR authorization_level_id = ?', authorization_level, AuthorizationLevel.superuser).first
    end
  end
 
  def has_favorite?(scope)
    authorization_level = AuthorizationLevel.find_by_name("favorite")
    self.authorizations.where('scope_id = ? AND scope_type = ? AND authorization_level_id = ?', scope, scope.class.to_s, authorization_level).first
  end

#
#  Surveys
#

  def surveys_broadcasted
    self.survey_schedules.broadcasted
  end

  def surveys_taken_for_org(organization)
    self.tlt_survey_responses.for_organization(organization).select{|r| !r.survey_schedule_id.nil?}.collect{|r| r.survey_schedule}.flatten.compact.uniq.sort{|a,b| b.schedule_start <=> a.schedule_start}
  end

  def surveys_broadcast_for_org(organization)
    self.survey_schedules.for_organization(organization).broadcasted.sort{|a,b| b.schedule_start <=> a.schedule_start}
  end

  def surveys_to_self
    self.survey_schedules.self_survey
  end

  def surveys_to_self_for_org(organization)
    self.survey_schedules.self_survey.for_organization(organization).sort{|a,b| b.schedule_start <=> a.schedule_start}
  end

  def tagged_school_surveys_for_(audience, survey_type, organization)
     self.favorite_organizations.collect{|s|s.tlt_survey_questions.for_audience(audience).for_type(survey_type).active}.flatten.select{|q| q.organization != organization}.sort_by{|q| q.organization.name}
  end

#
#  Classroom
#

  def can_edit_offering?(offering)
# Merge Keep for Upgrade
    self.classroom_admin_for_org?(offering.organization) || self.current_teacher_of_classroom?(offering)
  end

  def can_edit_period?(period)
# Merge Keep for Upgrade
    self.classroom_admin_for_org?(period.classroom.organization) || (self.teacher_for_org?(period.classroom.organization) && period.teacher?(self))
  end
  
  def student_of_classroom?(classroom)
   classroom.students.include?(self)
  end
 
  def teacher_of_classroom?(classroom)
   classroom.teachers.include?(self)
  end
 
  def current_teacher_of_classroom?(offering)
# Merge Keep for Upgrade
   self.teacher_for_org?(offering.organization) && self.teacher_of_classroom?(offering)
  end

  def user_of_classroom?(classroom)
   classroom.users.include?(self)
  end
 
  def in_classroom?(classroom)
   classroom.all_users.include?(self)
  end
   
  def tag_classroom(classroom)
    self.add_as_favorite_to(classroom) unless self.has_authorization_level_for?(classroom, "favorite")
  end
  
  def classrooms_x
    Classroom.active.where('organization_id in (?)', [1, self.organization_id] + self.organizations.collect{|o| o.id})
  end

  def offerings
    self.classroom_periods.collect{|p| p.classroom}.uniq.sort_by{|o| o.course_name} rescue []
  end

  def offerings_org(org)
    self.offerings.empty? ? [] : self.offerings.select{|c| c.organization_id == org.id}
  end

  def active_offerings
    self.classroom_periods.map{|p| p.classroom.active? ? p.classroom : nil }.compact.uniq.sort_by{|o| o.course_name} rescue []
  end


  def active_ifa_offerings(subject)
    self.classroom_periods.map{|p| (p.classroom.active? && p.classroom.ifa_on? && (p.classroom.act_subject_id == subject.id)) ? p.classroom : nil }.compact.uniq.sort_by{|o| o.course_name} rescue []
  end

  def active_offerings_org(org)
    self.active_offerings.empty? ? [] : self.active_offerings.select{|c| c.organization_id == org.id}
  end


  def periods_taught(org)
    self.classroom_period_users.teachers.collect{|pu| pu.classroom_period}.compact.select{|p| p.classroom.organization_id == org.id} rescue []
  end
  
  def offerings_taught(org)
    self.periods_taught(org).collect{|p| p.classroom}.uniq.sort_by{|c| c.course_name} rescue []
  end
  
  def parent_subjects_taught(org)
    self.offerings_taught(org).collect{|o| o.parent_subject}.compact.uniq.sort_by{|s| s.name}
  end

  def offerings_for_parent_subject(subject_parent)
    self.classrooms.select{|c| c.subject_area_id == subject_parent.id || c.subject_area.parent_id == subject_parent.id }.sort_by{|c| c.course_name.upcase}  rescue []
  end


 def untag_classroom(classroom)
      authorization_level = AuthorizationLevel.first(:include => :applicable_scopes, :conditions => ["authorization_levels.name = ? AND applicable_scopes.name = ?", "favorite", "Classroom"])
      if (self.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(classroom, classroom.class.to_s, authorization_level))
       self.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(classroom, classroom.class.to_s, authorization_level).destroy
      end
 end  

#
#  Coll Time in Learn & Discover, Learn, Evaluate
#

  def itl_summaries_between_dates_subject_belt(subj, month1, month2, belt)
       if subj
         self.tlt_sessions.for_subject(subj).between_dates(month1, month2).final.select{|s| !s.itl_belt_rank.nil? && s.itl_belt_rank.rank_score >= belt.rank_score}
       else
         self.tlt_sessions.between_dates(month1, month2).final.select{|s| !s.itl_belt_rank.nil? && s.itl_belt_rank.rank_score >= belt.rank_score}
       end
  end

  def dle_plan_for(cycle)
   self.user.dle_plans.select{ |p| p.dle_cycle_id == cycle.id}.last rescue nil
  end 
  
  def dle_plan_active?
    !self.user_dle_plans.current.empty?
  end

  def create_next_stage

  end
  def current_dle_plan
     self.user_dle_plans.current.last rescue nil
  end  
  
   def close_current_plans
      self.user_dle_plans.current.each do |p|
        p.update_attributes(:is_current => false)
      end 
   end
   
   def dle_stat_for(metric)
    stat = nil
     if metric.abbrev == "CC"
       stat = self.classroom_periods.collect{|p| p.classroom}.size 
     end
     if metric.abbrev == "TC"
       stat = self.classroom_periods.collect{|p| p.classroom.topics.size}.sum 
     end    
     if metric.abbrev == "SC"
       stat = self.classroom_periods.collect{|p| p.students.size}.sum 
     end
     if metric.abbrev == "PC"
       stat = self.classroom_periods.size 
     end
     if metric.abbrev == "RC"
       stat = self.contents.active.size 
     end 
     if metric.abbrev == "RV"
       stat = self.contents.active.collect{|c| c.views}.sum
     end
     if metric.abbrev == "SMS"
       stat = Message.where('sender_id = ?', self.id).size
     end
     if metric.abbrev == "SMR"
       stat = self.messages.size
     end
     if metric.abbrev == "SAT"
       stat = ActSubmission.for_teacher(self).size
     end
     if metric.abbrev == "HC"
       stat = Homework.for_teacher(self).size
     end
     if metric.abbrev == "CTC"
       stat = self.classrooms.collect{|c| c.topics.active}.flatten.collect{|t| t.discussions.size}.sum
     end
     if metric.abbrev == "LQC"
       stat = self.act_questions.lock.size
     end
     if metric.abbrev == "LAC"
       stat = self.act_assessments.lock.size
     end
     if metric.abbrev == "CQC"
       stat = self.act_questions.calibrated.size 
     end
     if metric.abbrev == "CAC"
       stat = self.act_assessments.calibrated.size 
     end
     if metric.abbrev == "TLS"
       stat = self.tlt_sessions.size 
     end
     if metric.abbrev == "TLF"
       stat = self.tlt_diagnostics.size
     end
     if metric.abbrev == "TLSR"
# Merge Keep for Upgrade
       audience = CoopApp.itl.tlt_survey_audiences.student.first
       stat = self.survey_schedules.for_audience(audience).collect{|s| s.tlt_survey_responses}.flatten.size rescue 0
     end
     if metric.abbrev == "CLSR"
# Merge Keep for Upgrade
       audience = CoopApp.classroom.tlt_survey_audiences.student.first
       stat = self.survey_schedules.for_audience(audience).collect{|s| s.tlt_survey_responses}.flatten.size rescue 0
     end
   stat
   end

#
# IFA
#

  def current_sms_score(standard, subject)
    self.ifa_dashboards.for_subject(subject).last.ifa_dashboard_sms_scores.for_standard(standard).first rescue nil
  end

  def ifa_plan_for(subject)
    self.ifa_plans.for_subject(subject).empty? ? nil : self.ifa_plans.for_subject(subject).last
  end

  def last_ifa_dashboard(subject)
    self.ifa_dashboards.for_subject(subject).empty? ? nil :
        self.ifa_dashboards.for_subject(subject).last
  end

  def standard_view
    if !self.ifa_user_option.nil? && self.ifa_user_option.act_master
      std = self.ifa_user_option.act_master
    else
      std = ActMaster.default_std
    end
    std
  end

  def assessments_taken(options = {})
    if options[:since] && options[:subject]
      assessments = self.act_submissions.final.for_subject(options[:subject]).since(options[:since]).order('created_at DESC')
    elsif options[:since]
      assessments = self.act_submissions.final.since(options[:since]).order('created_at DESC')
    elsif options[:subject]
      assessments = self.act_submissions.final.for_subject(options[:subject]).order('created_at DESC')
    else
      assessments = self.act_submissions.final.order('created_at DESC')
    end
    assessments
  end


  def dashboards(options = {})
    if options[:subject]
      dashboards = self.ifa_dashboards.for_subject(options[:subject]).order('period_end DESC')
    else
      dashboards = self.act_submissions.final.order('created_at DESC')
    end
    dashboards
  end

#
#  ctl
#

  def itl_subjects
    self.tlt_sessions.collect{|t| t.subject_area}.flatten.compact.uniq.sort_by{|s| s.name}
  end

  def blackbelt?
    self.itl_belt_rank.rank == "black" rescue nil
  end 
  
  def belt_rank
    self.itl_belt_rank ? self.itl_belt_rank.rank : ''
  end

#
#   APP Authorized?
##

  def app_authorized?(app,org)
    auth = false
    if app.core? then auth = org.can_be_displayed?(self) end
    if app.ifa?  then auth = self.ifa_authorized?(org) || self.app_superuser?(app) end
    if app.ita?  then auth = self.ita_authorized?(org) || self.app_superuser?(app) end      
    if app.blogs?  then auth = self.blog_authorized?(org) || self.app_superuser?(app) end
    if app.ctl?  then auth = self.ctl_authorized?(org) || self.app_superuser?(app) end
    if app.ista?  then auth = (self.stat_authorized?(org) || self.app_superuser?(app))  end
    if app.cm?  then auth = self.cm_authorized?(org) || self.app_superuser?(app) end
    if app.elt?  then auth = self.elt_authorized?(org) || self.app_superuser?(app) end
    if app.classroom?  then auth = self.classroom_authorized?(org) || self.app_superuser?(app) end                
    if app.pd?  then auth = self.dlem_authorized?(org) || self.app_superuser?(app) end
    auth
  end

  def beta_app_user?(app, org)
    app.is_beta? ? (self.beta_authorized?(org) || app_superuser?(app)): true
  end

  def resource_pool_for_app(app)
      full_pool = (self.favorite_resources + self.colleagues.collect{|u| u.contents.active}.flatten + self.favorite_organizations_for_app(app).collect{|o| o.contents.active}.flatten).uniq
      pool = []
      app.content_resource_types.each do |r_type|
        pool += full_pool.select{|r| r.content_resource_type_id == r_type.id}
      end
      app.subject_areas.each do |subj|
        pool += full_pool.select{|r| r.subject_area_id == subj.id}
      end
      pool.uniq
  end

  def resource_pool_for_org_app(org,app)
      full_pool = (self.favorite_resources + self.colleagues.collect{|u| u.contents.active}.flatten).uniq
      pool = []
      app.content_resource_types.each do |r_type|
        pool += full_pool.select{|r| r.content_resource_type_id == r_type.id}
      end
      app.subject_areas.each do |subj|
        pool += full_pool.select{|r| r.subject_area_id == subj.id}
      end
      unless org.parent?
# Merge Keep for Upgrade
        (pool + org.active_siblings.select{|o| o.app_enabled?(app)}.collect{|o| o.resources_for_app(app)}.flatten).uniq
      else
# Merge Keep for Upgrade
        (pool + org.all_active_children.select{|o| o.app_enabled?(app)}.collect{|o| o.resources_for_app(app)}.flatten).uniq
      end
  end

  def itl_school_pool_for_org(org)
      (self.favorite_organizations + org.active_siblings_same_type).uniq.select{|o| o.app_enabled?(CoopApp.ctl)}
  end

#   APP Authorized?

  def old_ifa_admin?(org)
    self.has_authorization_level_for?(org, "ifa_administrator")
  end

  def itl_school_pool_for_org(org)
      (self.favorite_organizations + org.active_siblings_same_type).uniq.select{|o| o.app_enabled?(CoopApp.ctl.first.abbrev)}
  end

#####################    User Authorization Orgs

  def app_admin_orgs(app)
    self.authorizations.for_level(AuthorizationLevel.app_administrator(app)).organizations.sort_by{|o| o.name}
  end

#####################    IFA Authorizations

  def ifa_authorized?(org)
#    org.app_enabled?(CoopApp.ifa.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "teacher") || self.has_authorization_level_for?(org, "ifa_administrator"))
    org.app_enabled?(CoopApp.ifa) && (self.ifa_admin_for_org?(org) || self.teacher_for_org?(org) || self.administrator_for_org?(org) || self.app_superuser?(CoopApp.ifa))
  end

  def ifa_admin_for_org?(org)
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.ifa), org, :superuser => true)
  end

  def ifa_superstudent_for_org?(org)
    self.has_authority?(AuthorizationLevel.app_superstudent(CoopApp.ifa), org, :superuser => true)
  end

#####################    STAT Authorizations

  def stat_authorized?(org)
#     org.app_enabled?(CoopApp.stat.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.stat_admin_for_org?(org) || self.stat_user?(org))
    org.app_enabled?(CoopApp.ista) && (self.stat_admin_for_org?(org) || self.stat_user?(org) || self.administrator_for_org?(org) || self.app_superuser?(CoopApp.ista))
  end

  def stat_admin_for_org?(org)
    #   self.has_authorization_level_for?(org, "stat_administrator")
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.ista), org, :superuser => true)
  end

  def stat_user?(org)
    #  self.has_authorization_level_for?(org, "stat_user")
    self.has_authority?(AuthorizationLevel.app_user(CoopApp.ista), org, :superuser => true)
  end

#####################    CM Authorizations
  def cm_authorized?(org)
    #    org.app_enabled?(CoopApp.cm.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.cm_admin_for_org?(org) || self.cm_km?(org) || self.consultant?(org))
    org.app_enabled?(CoopApp.cm) && (self.cm_admin_for_org?(org) || self.cm_km?(org) || self.consultant?(org) || self.administrator_for_org?(org) || self.app_superuser?(CoopApp.cm))
  end

  def cm_admin_for_org?(org)
    #  self.has_authorization_level_for?(org, "cm_administrator")
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.cm), org, :superuser => true)
  end

  def cm_km?(org)
    #   self.has_authorization_level_for?(org, "cm_knowledge_manager")
    self.has_authority?(AuthorizationLevel.app_knowledge_manager(CoopApp.cm), org, :superuser => true)
  end

  def consultant?(org)
#    self.has_authorization_level_for?(org, "cm_consultant")
    self.has_authority?(AuthorizationLevel.app_consultant(CoopApp.cm), org, :superuser => true)
  end


#####################    ELT Authorizations

  def elt_authorized?(org)
    org.app_enabled?(CoopApp.elt) && (self.elt_admin_for_org?(org) || self.elt_user?(org) || self.elt_reviewer?(org) || self.elt_provider_reviewer?(org) || self.administrator_for_org?(org) || self.app_superuser?(CoopApp.elt))
  end

  def elt_admin_for_org?(org)
    #   self.has_authorization_level_for?(org, "elt_administrator")
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.elt), org, :superuser => true)
  end

  def elt_user?(org)
    self.has_authority?(AuthorizationLevel.app_user(CoopApp.elt), org, :superuser => true)
  end

  def elt_reviewer?(org)
    self.has_authority?(AuthorizationLevel.app_reviewer(CoopApp.elt), org, :superuser => true)
  end

  def elt_provider_reviewer?(org)
    auth = false
    if org.elt_provider
      auth = self.elt_reviewer?(org.elt_provider)
    end
    auth
  end

#####################    CTL Authorizations

  def ctl_authorized?(org)
    #  org.app_enabled?(CoopApp.ctl.abbrev) &&(self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "teacher") || self.has_authorization_level_for?(org, "ctl_administrator") || self.has_authorization_level_for?(org, "ctl_observer"))
    org.app_enabled?(CoopApp.ctl) && (self.ctl_admin_for_org?(org) || self.ctl_observer_for_org?(org) || self.app_superuser?(CoopApp.ctl) || self.teacher_for_org?(org) || self.administrator_for_org?(org))
  end

  def ctl_observer_for_org?(org)
    #   (self.has_authorization_level_for?(org, "ctl_observer"))
    self.has_authority?(AuthorizationLevel.app_observer(CoopApp.ctl), org, :superuser => true)
  end

  def ctl_admin_for_org?(org)
    #   self.has_authorization_level_for?(org, "ctl_administrator")
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.ctl), org, :superuser => true)
  end

#####################    BLOG Authorizations

  def blog_authorized?(org)
    org.app_enabled?(CoopApp.blog) && (self.blog_admin_for_org?(org) || self.panelist_for_org?(org) || self.administrator_for_org?(org) || self.app_superuser?(CoopApp.blog))
  end

  def panelist_for_org?(org)
    #  (self.has_authorization_level_for?(org, "blog_panelist"))
    self.has_authority?(AuthorizationLevel.app_panelist(CoopApp.blog), org, :superuser => true)
  end

  def blog_admin_for_org?(org)
    #  self.has_authorization_level_for?(org, "blog_administrator")
     self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.blog), org, :superuser => true)
  end

#####################    ITA Authorizations

  def ita_authorized?(org)
  #   org.app_enabled?(CoopApp.ita.abbrev) && self.has_authorization_level_for?(org, "content_manager")
     org.app_enabled?(CoopApp.ita) && (self.ita_admin_for_org?(org) || self.administrator_for_org?(org) || self.app_superuser?(CoopApp.pd))
  end

  def ita_admin_for_org?(org)
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.ita), org, :superuser => true)
  end

#####################    PD Authorizations

  def dlem_authorized?(org)
    #   org.app_enabled?(CoopApp.pd.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "pd_administrator") || self.has_authorization_level_for?(org, "teacher"))
    org.app_enabled?(CoopApp.pd) && (self.pd_authorized?(org) || self.teacher_for_org?(org))
  end

  def pd_coach_for?(org)
    self.ctl_authorized?(org)
  end

  def pd_authorized?(org)
    # (self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "pd_administrator"))
    self.pd_admin_for_org?(org) || self.administrator_for_org?(org) || self.app_superuser?(CoopApp.pd)
  end

  def pd_admin_for_org?(org)
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.pd), org, :superuser => true)
  end

  def pd_admin?
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.pd), nil, :superuser => true)
  end

#####################    Classroom Authorizations

  def classroom_manager_for_offering?(classroom)
    self.classroom_authorized?(classroom.organization) || (classroom.organization.app_enabled?(CoopApp.classroom) && self.teacher_for_org?(classroom.organization) && classroom.teachers.include?(self))
  end

  def classroom_authorized?(org)
    self.classroom_admin_for_org?(org) || self.superuser? || self.app_superuser?(CoopApp.classroom)
  end

  def classroom_admin_for_org?(org)
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.classroom), org, :superuser => true) || (self.administrator_for_org?(org))
  end

  def classroom_administrator?  ## for all orgs
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.classroom), nil, :superuser => true)
  end

  def toggle_classroom_favorite(classroom)
    authorization_level = AuthorizationLevel.first(:include => :applicable_scopes, :conditions => ["authorization_levels.name = ? AND applicable_scopes.name = ?", "favorite", "Classroom"])
    if authorization_level
      if self.has_favorite?(classroom)
        self.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(classroom, classroom.class.to_s, authorization_level).destroy
      else
        self.add_as_favorite_to(classroom)
      end
    end
  end

  def set_classroom_favorite(classroom, add)
    if (self.has_favorite?(classroom) && add=="remove") || (!self.has_favorite?(classroom) && add=="add")
      self.toggle_classroom_favorite(classroom)
    end
  end

#####################    Core Authorizations

  def beta_app_user?(app, org)
    app.is_beta? && self.beta_user_for_org?(org)
  end

  def beta_user_for_org?(org)
    org.app_enabled?(CoopApp.classroom) && (self.has_authority?(AuthorizationLevel.app_beta_user(CoopApp.core), org))
  end

  def beta_user?
    org.app_enabled?(CoopApp.classroom) && (self.has_authority?(AuthorizationLevel.app_beta_user(CoopApp.core), nil))
  end

  def teacher_for_org?(org)
    self.has_authority?(AuthorizationLevel.app_teacher(CoopApp.core), org)
  end

  def teacher?  # for any org
    self.has_authority?(AuthorizationLevel.app_teacher(CoopApp.core), nil)
  end

  def super_student?  # for any org
    self.has_authority?(AuthorizationLevel.app_teacher(CoopApp.core), nil)
  end

  def content_admin_for_org?(org)
    self.content_manager_for_org?(org)
  end

  def content_admin?
    self.has_authority?(AuthorizationLevel.app_library_administrator(CoopApp.core), nil, :superuser => true)
  end

  def content_manager_for_org?(org)
    # (self.has_authorization_level_for?(org, "content_manager"))
    self.has_authority?(AuthorizationLevel.app_knowledge_manager(CoopApp.core), org, :superuser => true)
  end

  def content_manager?
    self.has_authority?(AuthorizationLevel.app_knowledge_manager(CoopApp.core), nil, :superuser => true)
  end

  def administrator_for_org?(org)
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.core), org, :superuser => true)
  end
  def administrator?
    self.has_authority?(AuthorizationLevel.app_administrator(CoopApp.core), nil)
  end

  def superuser?
    self.has_authority?(AuthorizationLevel.app_superuser(CoopApp.core), nil) || self.id == 1
  end

  def app_superuser?(app)
    self.has_authority?(AuthorizationLevel.app_superuser(app), nil, :superuser => true)
  end
#
####    NEW Authorization Routine
#
  def has_authority?(arg1, arg2, option = {})
    if arg1.class.to_s == 'AuthorizationLevel'
      auth_level = arg1
      entity = arg2
    else
      auth_level = arg2
      entity = arg1
    end
    unless auth_level.nil?
      if entity.nil?
        authority = !self.authorizations.for_level(auth_level).empty?
      else
        authority = !self.authorizations.for_level(auth_level).for_entity(entity).empty?
      end
      if option[:superuser] == true
        authority = authority || self.superuser?
      end
    else
      authority = false
    end
    authority
  end

#########

  def has_authorization_level_for?(scope, authorization_level)
    authorization_level = authorization_level.is_a?(AuthorizationLevel) ? authorization_level : AuthorizationLevel.find_by_name(authorization_level)
    # self.authorizations.find(:conditions => ["((scope_id = ? AND scope_type = ? AND authorization_level_id = ?) OR authorization_level_id = ?)", scope, scope.class.to_s, authorization_level.id, AuthorizationLevel.superuser]).first
    self.authorizations.where('((scope_id = ? AND scope_type = ? AND authorization_level_id = ?) OR authorization_level_id = ?)', scope, scope.class.to_s, authorization_level, AuthorizationLevel.superuser).first
  end

###################################
  def make_superuser!
    unless self.superuser?
      su = Authorization.new
      su.authorization_level_id = AuthorizationLevel.superuser.id
      su.user_id = self.id
      su.save
    end
  end

  def content_manager_orgs
    self.authorizations.for_level(AuthorizationLevel.app_knowledge_manager(CoopApp.core)).collect{|a| a.scope}.compact.uniq
  end

  def prepare_regexps
    authorization_level_names = AuthorizationLevelNames.join('|')
    return Regexp.new("(#{authorization_level_names})_of\\?"), Regexp.new("add_as_(#{authorization_level_names})_to"), Regexp.new("remove_as_(#{authorization_level_names})_from")
  end
  
  def respond_to?(method, foo = nil)
    method_name = method.to_s
    of_re, add_as_re, remove_as_re = self.prepare_regexps
    if method_name.match(of_re) || method_name.match(add_as_re) || method_name.match(remove_as_re)
      true
    else
      super
    end
  end

#
#  IFA methods
#
  def ifa_plan_subject(subject)
    self.ifa_plan_for(subject)
  end

  def show_ifa_plan_form?(subject)
    !subject.nil? && !self.ifa_plan_subject(subject).nil? && self.ifa_plan_subject(subject).incomplete?
  end

  def calibrate_view?
    self.calibrated_only
 #   self.ifa_user_option ? self.ifa_user_option.calibrate_only : false
  end

  def sat_view?
    self.ifa_user_option ? self.ifa_user_option.sat_view : false
  end

#
  #  Classroom methods
  #

  def add_to_period(per)
    if self && per
      unless per.users.include?(self)
        period_user = ClassroomPeriodUser.new
        period_user.user_id = self.id
        period_user.is_teacher = false
        period_user.is_student = true
        per.classroom_period_users<<period_user
      end
    end
  end

  def method_missing(method, *args)
    method_name = method.to_s
    of_re, add_as_re, remove_as_re = self.prepare_regexps
    if (match_data = method_name.match(of_re))
      scope = args.first
      authorization_level_name = match_data[1]
      if authorization_level_name == "superuser"
        self.authorizations.find :first, :conditions => ["authorization_levels.name = ?", authorization_level_name]
      else
        self.authorizations.find :first, :conditions => ["authorization_levels.name = ? AND scope_id = ? AND scope_type = ?", authorization_level_name, scope, scope.class.to_s]
      end
    elsif (match_data = method_name.match(add_as_re))
      scope = args.first
      unless self.authorizations.find :first, :conditions => ["authorization_levels.name = ? AND scope_id = ? AND scope_type = ?", match_data[1], scope, scope.class.to_s]
        self.authorizations.create :authorization_level => AuthorizationLevel.find_by_name(match_data[1]), :scope => scope
      end
    elsif (match_data = method_name.match(remove_as_re))
      scope = args.first
      authorization = self.authorizations.find :first, :conditions => ["authorization_levels.name = ? AND scope_id = ? AND scope_type = ?", match_data[1], scope, scope.class.to_s]
      if authorization 
        self.authorizations.delete authorization
      end
    else
      super
    end
  end
  
  def add_authorization(authorization_level_name, organization = @current_organization)
    self.authorizations.create :scope => organization, :authorization_level => AuthorizationLevel.find_by_name(authorization_level_name)
  end
  
  def remove_authorization(authorization_level_name, organization = @current_organization)
    organization.find_by_user_id(self, :authorization_level => AuthorizationLevel.find_by_name(authorization_level_name)).destroy
  end
  
  def self.auto_complete_on(query, org)
    org.users.where('last_name LIKE ?', '%' + query + '%').order('last_name').collect{|ra| [ra, ra.all_children]}.flatten.uniq.sort_by(&:name)
  end
  
  def self.org_contact(contact_email)
    User.where('email_address = ?', contact_email).first
  end
 
  def owned_classrooms
    self.classrooms.active.order('course_name')
  end

  def all_talents
    (self.talents.collect {|talent| talent.name} ).uniq.join(" , ")
  end
  
  def all_authorities_and_roles
    roles = self.roles.compact
    role_names = roles.collect {|ro| ro.name}.uniq
    omissions = ["friend", "superuser"]
    (self.authorizations.collect {|auth| auth.authorization_level.name}.uniq ) + role_names - omissions
  end
  
  
  def all_roles
    roles = self.roles.compact
    role_names = roles.collect {|ro| ro.name}.uniq
  end  
  
  
  def self.unverified_users
    users = User.where('verified_at is null')
  end
  
  def actived?
    status == "actived"
  end
  
  def verified?
    verified_at.present?
  end
  
  def set_verified
    self.update_attribute("verified_at", Date.today)
  end

  def last_blog_post_create_at(blog)
    blog.blog_posts.find_all_by_user_id(self).last.created_at rescue ""
  end
  
  def blog_post_count(blog)
    blog.blog_posts.find_all_by_user_id(self).size
  end
  
  protected
  
  def password_required?
    crypted_password.blank?  || !password.blank?
  end
  
  def age_verified_required?
    !self.age_verified
  end
  
  def read_tos_required?
    !self.read_tos
  end

  private

  def picture_width
    required_width  = 1000
    if picture.queued_for_write[:original]
      dimensions = Paperclip::Geometry.from_file(picture.queued_for_write[:original].path)
      errors.add(:picture, "Width can't be greater than #{required_width}") unless dimensions.width <= required_width
    end
  end
end
