class User < ActiveRecord::Base
  require 'digest/sha1'
  require 'resolv'
  require 'authorization_requirement'  
  include PublicPersona

  has_attached_file :picture, :styles => { :thumb => "118x166#", :med_thumb => "80x112#", :small_thumb => "50x50#" }

  belongs_to :act_master
  belongs_to :organization, :foreign_key => "home_org_id" 
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
  has_many :elt_cases_reviewed, :class_name => 'EltCase', :foreign_key => "reviewer_id"
  
  has_many :user_dle_plans, :dependent => :destroy
  has_many :dle_coach_assignments, :dependent=> :destroy
  has_many :coachees, :through => :dle_coach_assignments

  has_many :client_assignments, :dependent=> :destroy
  has_many :clients, :through => :client_assignments
      
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
  
  named_scope :not_students, :conditions => ["is_student = ?", false], :order => "last_name"
  named_scope :students, :conditions => ["is_student = ?", true], :order => "last_name"
  named_scope :with_email, lambda{|email| {:conditions => ["email_address = ? ", email]}}
  named_scope :with_preferred_email, lambda{|email| {:conditions => ["preferred_email = ? ", email]}}
  named_scope :with_alt_login, lambda{|email| {:conditions => ["alt_login = ? ", email]}}
  named_scope :by_name_asc, :order => "last_name asc"
  named_scope :by_name_desc, :order => "last_name desc"
  named_scope :by_register_asc, :order => "created_at asc"
  named_scope :by_register_desc, :order => "created_at desc"
  named_scope :by_last_logon_asc, :order => "last_logon asc"
  named_scope :by_last_logon_desc, :order => "last_logon desc"
  named_scope :active, :conditions => ["is_suspended = ?", false]
  named_scope :suspended, :conditions => ["is_suspended = ?", true]
    
  named_scope :with_names, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(verified_at IS NOT NULL AND first_name LIKE ? OR last_name LIKE ?)'
      conditions << "%#{keyword}%"
      conditions << "%#{keyword}%"
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "last_name, first_name")
    {:conditions => conditions, :order => order_by}
  }
 
  named_scope :with_roles, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
     condition_strings << '(roles.name LIKE ?)'
    conditions << "%#{keyword}%"
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "last_name, first_name") 
    {:conditions => conditions, :include => "roles", :order => order_by}
  }

  named_scope :with_talent, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(talents.name REGEXP ? OR talents.name REGEXP ? OR credentials REGEXP ? OR credentials REGEXP ? OR roles.name REGEXP ? OR last_name REGEXP ?)'
      conditions << "^#{keyword}"
      conditions << "\s+#{keyword}" 
      conditions << "^#{keyword}"
      conditions << "\s+#{keyword}" 
      conditions << "^#{keyword}"
      conditions << "^#{keyword}"
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "last_name, first_name") 
    {:conditions => conditions, :include => ["talents", "roles"], :order => order_by}
  }
  
  named_scope :with_organizations, lambda { |keywords, options|
    role_ids = Organization.with_names(keywords,{}).collect{|o| o.roles.collect{|r| r.id}}.flatten
    order_by = (options[:order] || "last_name, first_name")    
    {:conditions => ["role_memberships.role_id IN (?)", role_ids], :include => [ :role_memberships], :order => order_by}
  }
  
  def self.generate_password(length = 10)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    password = ""
    1.upto(length) { |i| password << chars[rand(chars.size-1)] }
    password
  end
  
  def before_save
     self.last_name = self.last_name.strip.titleize.delete(" ")
     self.first_name = self.first_name.strip.humanize
  end
  
  def after_initialize
 #    self.country = "US" if self.country.nil?
  end

  def home_organization
    Organization.find_by_id(self.home_org_id) rescue nil
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
  
  def favorite_organizations
    authorization_level = AuthorizationLevel.find_by_name("friend")
    Organization.find(:all, :conditions => ["(authorizations.user_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ? AND status_id = ?)", self.id, "Organization", authorization_level.id, 1], :include => "authorizations", :order => "name")
  end

  def favorite_other_organizations
    authorization_level = AuthorizationLevel.find_by_name("friend")
    favs = Organization.find(:all, :conditions => ["(authorizations.user_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ? AND status_id = ?)", self.id, "Organization", authorization_level.id, 1], :include => "authorizations", :order => "name")
    self.organization.nil? ? favs : favs.select{|o| o.id != self.organization_id}
  end

  def my_schools
    if self.organization
      (self.favorite_organizations + self.organization.active_siblings_same_type).compact.uniq
    else
     self.favorite_organizations
    end 
  end

  def my_schools_for_app(app)
    self.my_schools.select{|org| org.app_enabled?(app.abbrev)}.uniq.sort_by{|o| o.name}
  end


  def favorite_organizations_for_app(app)
    self.favorite_organizations.select{|org| org.app_enabled?(app.abbrev)}
  end

  def favorite_organizations_type_for_app(app, type)
    self.favorite_organizations.select{|org| org.app_enabled?(app.abbrev) && org.organization_type_id == type.id}
  end

  
  def current_grade_level
    grade_level = 0
    home_org = self.home_organization rescue nil
    if self.student_demographic && home_org
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
#    self.authorizations.colleague.collect{|a| a.scope}
     fol_auths = Authorization.find(:all, :conditions => ["scope_type = ? AND authorization_level_id = ? AND scope_id = ?", "User", AuthorizationLevel.colleague, self])
     followers = []
     fol_auths.each do |ca|
     followers << User.find(:first, :conditions => ["id= ?", ca.user_id])
    end
    followers
  end

  def favorite_classrooms
    favorites = []
    authorization_level = AuthorizationLevel.find_by_name("favorite")
    favorites += Classroom.find(:all, :conditions => ["(authorizations.user_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ?)", self.id, "Classroom", authorization_level.id], :include => "authorizations", :order => "course_name")
    favorites.compact.select{ |c| c.organization}.uniq
  end



  def lead_classrooms
#   Classroom.active.find(:all)
#   Classroom.active.find(:all, :include => :authorizations, :conditions => ["users.id != ? AND authorizations.authorization_level_id = ? AND (authorizations.user_id = ? OR authorizations.scope_id = ?)", self, AuthorizationLevel.favorite, self, self])
    favs = Authorization.find(:all, :conditions => ["scope_type = ? AND authorization_level_id = ? AND user_id = ?", "Classroom", AuthorizationLevel.leader, self])
    rooms = []
    favs.each do |fc|
    rooms << Classroom.find(:first, :conditions => ["id= ?", fc.scope_id])
   end
  rooms
  end

  def participate_classrooms
#   Classroom.active.find(:all)
#   Classroom.active.find(:all, :include => :authorizations, :conditions => ["users.id != ? AND authorizations.authorization_level_id = ? AND (authorizations.user_id = ? OR authorizations.scope_id = ?)", self, AuthorizationLevel.favorite, self, self])
    favs = Authorization.find(:all, :conditions => ["scope_type = ? AND authorization_level_id = ? AND user_id = ?", "Classroom", AuthorizationLevel.participant, self])
    rooms = []
    favs.each do |fc|
    rooms << Classroom.find(:first, :conditions => ["id= ?", fc.scope_id])
   end
  rooms
  end


  def favorite_resources
    authorization_level = AuthorizationLevel.find_by_name("favorite")
    Content.find(:all, :conditions => ["(authorizations.user_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ? AND !is_delete)", self.id, "Content", authorization_level.id], :include => "authorizations", :order => "title")
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
    ms = Message.find(:all, :conditions=>["sender_id = ? && created_at >= ? && created_at <= ?", self.id, start_date, end_date]).size rescue 0
  end   
#
#  Messages Received
#
  def mr(start_date, end_date)
     mr = Message.find(:all, :conditions=>["user_id = ? && created_at >= ? && created_at <= ?", self.id, start_date, end_date]).size rescue 0
  end   
#
#  Assessments Taken By User's Students
#
  def sat(start_date, end_date)
    a_count = 0
    teacher_assessments = ActSubmission.find(:all, :conditions => ["teacher_id = ? && created_at >= ? && created_at <= ?", self.id, start_date, end_date]) rescue nil
    if teacher_assessments
       a_count = teacher_assessments.size
   end
   a_count
  end   
#
#  Assessments Reviewed By User's Students
#
  def sar(start_date, end_date)
    a_count = 0
    teacher_assessments = ActSubmission.find(:all, :conditions => ["teacher_id = ? && created_at >= ? && created_at <= ?", self.id, start_date, end_date]) rescue nil
    if teacher_assessments
       a_count = teacher_assessments.select{|ass| ass.date_finalized}.size rescue 0
   end
   a_count
  end
#
#  Average Student Mastery Level
#
  def asml(subject_id,start_date, end_date, current_standard, org)
    answer_list = ActAnswer.find(:all, :conditions=>["teacher_id = ? && organization_id = ?  && created_at >= ? && created_at <= ?&& was_selected", self.id, org.id, start_date, end_date]) rescue nil
    sms_level = current_standard.sms(answer_list, subject_id, 0,0, org.id)
  end
#
#  Locked Assessment Questions Created by Teacher
#
  def lqc(start_date, end_date)
    question_list = ActQuestion.find(:all, :conditions=>["user_id = ? && updated_at >= ? && updated_at <= ? && is_locked", self.id, start_date, end_date]) rescue nil
  end  
#
#  Calibrated Assessment Questions Created by Teacher
#
  def cqc(start_date, end_date)
    question_list = ActQuestion.find(:all, :conditions=>["user_id = ? && updated_at >= ? && updated_at <= ? && is_calibrated", self.id, start_date, end_date]) rescue nil
  end   
#
#  Locked Assessment Created by Teacher
#
  def lac(start_date, end_date)
    assess_list = ActAssessment.find(:all, :conditions=>["user_id = ? && updated_at >= ? && updated_at <= ? && is_locked", self.id, start_date, end_date]) rescue nil
  end  
#
#  Calibrated Assessments Created by Teacher
#
  def cac(start_date, end_date)
    assess_list = ActAssessment.find(:all, :conditions=>["user_id = ? && updated_at >= ? && updated_at <= ? && is_calibrated", self.id, start_date, end_date]) rescue nil
  end  
  
  def set_default_registration_values(org_id)
    self.home_org_id = self.home_org_id.nil? ? org_id : self.home_org_id
    self.organization_id = self.home_org_id
    self.is_suspended = false
    self.Provider_of_Texting_Service = "No Texting Wanted" if self.Provider_of_Texting_Service.nil?
    self.preferred_email = email_address
    self.act_master_id = ActMaster.find(:first).id

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
  
  def validate
    unless self.email_address.blank?
      unless self.has_valid_email_address?(:verify_domain => false)
        errors.add(:email_address, "is invalid")
      end
    end
  end
  
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

  def send_new_password
    new_pass = User.generate_password
    self.password = self.password_confirmation = new_pass
    self.save
    Notifier.deliver_forgot_password(self, new_pass)
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
    self.authorizations.find(:all, :conditions => ["(scope_id = ? AND scope_type = ?) OR authorization_level_id = ?", scope, scope.class.to_s, AuthorizationLevel.superuser]).any? do |authorization|
      authorization.authorization_level.authorized_for_action?(action.to_s)
    end
  end
  
  def has_authorization_level_for?(scope, authorization_level)
    authorization_level = authorization_level.is_a?(AuthorizationLevel) ? authorization_level : AuthorizationLevel.find_by_name(authorization_level)
    self.authorizations.find(:first, :conditions => ["((scope_id = ? AND scope_type = ? AND authorization_level_id = ?) OR authorization_level_id = ?)", scope, scope.class.to_s, authorization_level, AuthorizationLevel.superuser])
  end
  
  def has_authorization_level?(authorization_level, options={})
    authorization_level = authorization_level.is_a?(AuthorizationLevel) ? authorization_level : AuthorizationLevel.find_by_name(authorization_level)
    if options[:ignore_superuser]
      self.authorizations.find(:first, :conditions => ["(authorization_level_id = ?)", authorization_level])
    else
      self.authorizations.find(:first, :conditions => ["((authorization_level_id = ?) OR authorization_level_id = ?)", authorization_level, AuthorizationLevel.superuser])
    end
  end
 
  def has_favorite?(scope)
    authorization_level = AuthorizationLevel.find_by_name("favorite")
    self.authorizations.find(:first, :conditions => ["(scope_id = ? AND scope_type = ? AND authorization_level_id = ?)", scope, scope.class.to_s, authorization_level])
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
    self.classroom_admin?(offering.organization) || self.current_teacher_of_classroom?(offering)
  end

  def can_edit_period?(period)
    self.classroom_admin?(period.classroom.organization) || (self.teacher?(period.classroom.organization) && period.teacher?(self))
  end
  
  def student_of_classroom?(classroom)
   classroom.students.include?(self)
  end
 
  def teacher_of_classroom?(classroom)
   classroom.teachers.include?(self)
  end
 
  def current_teacher_of_classroom?(offering)
   self.teacher?(offering.organization) && self.teacher_of_classroom?(offering)
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
  
  def classrooms
    Classroom.find(:all, :conditions => ["organization_id in (?) AND status = 'active'", [1, self.home_organization.id] + self.organizations.collect{|o| o.id}])  
  end

  def offerings
    self.classroom_periods.collect{|p| p.classroom}.uniq.sort_by{|o| o.course_name} rescue []
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
         TltSession.find(:all, :conditions => ["user_id = ? AND subject_area_id = ? AND session_date >= ? AND session_date <= ? AND is_final", self.id, subj.id, month1, month2]).select{|s| !s.itl_belt_rank.nil? && s.itl_belt_rank.rank_score >= belt.rank_score}
       else
         TltSession.find(:all, :conditions => ["user_id = ? AND session_date >= ? AND session_date <= ? AND is_final", self.id, month1, month2]).select{|s| !s.itl_belt_rank.nil? && s.itl_belt_rank.rank_score >= belt.rank_score}
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
       stat = Message.find(:all, :conditions=>["sender_id = ?", self.id]).size rescue 0
     end
     if metric.abbrev == "SMR"
       stat = Message.find(:all, :conditions=>["user_id = ? ", self.id]).size rescue 0
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
       stat = self.act_questions.locked.size 
     end
     if metric.abbrev == "LAC"
       stat = self.act_assessments.locked.size 
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
       audience = CoopApp.itl.first.tlt_survey_audiences.student.first
       stat = self.survey_schedules.for_audience(audience).collect{|s| s.tlt_survey_responses}.flatten.size rescue 0
     end
     if metric.abbrev == "CLSR"
       audience = CoopApp.classroom.first.tlt_survey_audiences.student.first
       stat = self.survey_schedules.for_audience(audience).collect{|s| s.tlt_survey_responses}.flatten.size rescue 0
     end
   stat
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
    if app.ifa?  then auth = self.ifa_authorized?(org) || self.app_superuser?(app) end
    if app.ita?  then auth = self.ita_authorized?(org) || self.app_superuser?(app) end      
    if app.blogs?  then auth = self.blog_authorized?(org) || self.app_superuser?(app) end
    if app.ctl?  then auth = self.itl_authorized?(org) || self.app_superuser?(app) end
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
        (pool + org.active_siblings.select{|o| o.app_enabled?(app.abbrev)}.collect{|o| o.resources_for_app(app)}.flatten).uniq
      else
        (pool + org.all_active_children.select{|o| o.app_enabled?(app.abbrev)}.collect{|o| o.resources_for_app(app)}.flatten).uniq         
      end
  end

  def admin?(org)
    self.has_authorization_level_for?(org, "administrator")
  end

  def beta_authorized?(org)
    self.has_authorization_level_for?(org, "beta_user")
  end

  def ifa_admin?(org)
    self.has_authorization_level_for?(org, "ifa_administrator")
  end

  def itl_school_pool_for_org(org)
      (self.favorite_organizations + org.active_siblings_same_type).uniq.select{|o| o.app_enabled?(CoopApp.ctl.first.abbrev)}
  end

  def ifa_authorized?(org)
    org.app_enabled?(CoopApp.ifa.first.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "teacher") || self.has_authorization_level_for?(org, "ifa_administrator"))
  end

  def stat_authorized?(org)
     org.app_enabled?(CoopApp.ista.first.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.stat_admin?(org) || self.stat_user?(org))
  end

  def stat_admin?(org)
    self.has_authorization_level_for?(org, "stat_administrator")
  end

  def stat_user?(org)
    self.has_authorization_level_for?(org, "stat_user")
  end

  def cm_authorized?(org)
     org.app_enabled?(CoopApp.cm.first.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.cm_admin?(org) || self.cm_km?(org) || self.consultant?(org))
  end

  def cm_admin?(org)
    self.has_authorization_level_for?(org, "cm_administrator")
  end

  def cm_km?(org)
    self.has_authorization_level_for?(org, "cm_knowledge_manager")
  end

  def consultant?(org)
    self.has_authorization_level_for?(org, "cm_consultant")
  end
  
  def elt_authorized?(org)
     org.app_enabled?(CoopApp.elt.first.abbrev) && (self.elt_admin?(org) || self.elt_team?(org) || self.elt_reviewer?(org) || self.elt_provider_reviewer?(org) )  
  end

  def elt_admin?(org)
    self.has_authorization_level_for?(org, "elt_administrator")
  end

  def elt_team?(org)
    self.has_authorization_level_for?(org, "elt_team_member")
  end

  def elt_reviewer?(org)
    self.has_authorization_level_for?(org, "elt_reviewer")
  end

  def elt_provider_reviewer?(org)
    auth = false
    if org.elt_provider
      auth = self.authorizations.find(:first, :conditions => ["(scope_id = ? AND scope_type = ? AND authorization_level_id = ?)", org.elt_provider.id, org.class.to_s, AuthorizationLevel.elt_reviewer.id])
    end 
    auth
  end
   
  def itl_authorized?(org)
     org.app_enabled?(CoopApp.ctl.first.abbrev) &&(self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "teacher") || self.has_authorization_level_for?(org, "ctl_administrator") || self.has_authorization_level_for?(org, "ctl_observer"))
  end

  def itl_observer?(org)
     (self.has_authorization_level_for?(org, "ctl_observer"))
  end

  def ctl_admin?(org)
    self.has_authorization_level_for?(org, "ctl_administrator")
  end

  def blog_authorized?(org)
     org.app_enabled?(CoopApp.blog.first.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "blog_panelist")) 
  end

  
  def blog_authorized?(org)
     org.app_enabled?(CoopApp.blog.first.abbrev) && (self.blog_admin?(org) || self.blogger?(org) )  
  end

  def blogger?(org)
     (self.has_authorization_level_for?(org, "blog_panelist"))
  end

  def blog_admin?(org)
    self.has_authorization_level_for?(org, "blog_administrator")
  end

  def ita_authorized?(org)
     org.app_enabled?(CoopApp.ita.first.abbrev) && self.has_authorization_level_for?(org, "content_manager") 
  end

  def classroom_authorized?(org)
     org.app_enabled?(CoopApp.classroom.first.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "classroom_manager") || self.has_authorization_level_for?(org, "teacher"))  
  end

  def classroom_admin?(org)
     org.appl_enabled?(CoopApp.classroom.first) && (self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "classroom_manager"))  
  end

  def teacher?(org)
     org.app_enabled?(CoopApp.classroom.first.abbrev) && (self.has_authorization_level_for?(org, "teacher"))  
  end

  def content_manager_for_org?(org)
     (self.has_authorization_level_for?(org, "content_manager"))  
  end

  def content_admin?(org)
    self.has_authorization_level_for?(org, "content_administrator")
  end

  def classroom_manager_for?(classroom)
    classroom.organization.app_enabled?(CoopApp.classroom.first.abbrev) && (self.has_authorization_level_for?(classroom.organization, "teacher") || self.has_authorization_level_for?(classroom.organization, "classroom_manager")) && classroom.teachers.include?(self)
  end


  def dlem_authorized?(org)
     org.app_enabled?(CoopApp.pd.first.abbrev) && (self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "pd_administrator") || self.has_authorization_level_for?(org, "teacher"))  
  end

  def pd_coach_for?(org)
     self.itl_authorized?(org)  
  end

  def pd_authorized_for?(org)
     (self.has_authorization_level_for?(org, "administrator") || self.has_authorization_level_for?(org, "pd_administrator"))  
  end

  def content_manager?
    self.has_authorization_level?("content_manager", :ignore_superuser => true)
  end
  
  def superuser?
    self.superuser_of?(nil)
  end

  def make_superuser!
    unless self.superuser?
      su = Authorization.new
      su.authorization_level_id = AuthorizationLevel.superuser.id
      su.user_id = self.id
      su.save
    end
  end

  def app_superuser?(app)
    self.has_authorization_level_for?(app, "app_superuser") || self.superuser?
  end

  def an_app_superuser?
    self.has_authorization_level?("app_superuser")
  end

  def content_manager_orgs
    self.authorizations.content_manager.collect{|a| a.scope}.compact.uniq
  end
  
  def prepare_regexps
    authorization_level_names = AuthorizationLevelNames.join('|')
    return Regexp.new("(#{authorization_level_names})_of\\?"), Regexp.new("add_as_(#{authorization_level_names})_to"), Regexp.new("remove_as_(#{authorization_level_names})_from")
  end
  
  def respond_to?(method)
    method_name = method.to_s
    of_re, add_as_re, remove_as_re = self.prepare_regexps
    if method_name.match(of_re) || method_name.match(add_as_re) || method_name.match(remove_as_re)
      true
    else
      super
    end
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
    org.users.find(:all, :conditions => ["last_name LIKE ?", '%' + query + '%'], :order => "last_name").collect{|ra| [ra, ra.all_children]}.flatten.uniq.sort_by(&:name)
  end
  
  def self.with_out_role(role)
    User.find(:all, :conditions => ["NOT id IN (SELECT user_id FROM role_memberships WHERE role_id = ?) AND religious_affiliation_id IS NOT NULL", role],  :include => "role_memberships", :order => "last_name, first_name")
  end
  
  def self.with_role(role)
    User.find(:all, :conditions => ["(role_memberships.role_id = ?)", role],  :include => "role_memberships", :order => "last_name, first_name")
  end
  
  def self.with_authorization_level(authorization_level)
   User.find(:all, :conditions => ["(authorizations.scope_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ?)", @current_organization, "Organization", authorization_level], :include => "authorizations", :order => "last_name, first_name")
  end
    
  def self.who_are_friends(organization_id)
    User.find(:all, :conditions => ["(authorizations.scope_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ?)", organization_id, "Organization", AuthorizationLevel.friend], :include => "authorizations", :order => "last_name, first_name")
  end
  
  def self.who_are_authorized(organization_id, authorization_level_id)
    User.find(:all, :conditions => ["(authorizations.scope_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ?)", organization_id, "Organization", authorization_level_id], :include => "authorizations", :order => "last_name, first_name")
  end
  
  def self.org_contact(contact_email)
    User.find(:first, :conditions => ["(email_address = ?)", contact_email]) rescue nil
  end
 
  def owned_classrooms
    Classroom.active.find(:all, :conditions => ["(user_id = ? )", self.id], :order => "course_name")
  end

  def all_talents
    (self.talents.collect {|talent| talent.name} ).uniq.join(" , ")
  end
  
  def all_authorities_and_roles
    roles = self.roles.find(:all).compact
    role_names = roles.collect {|ro| ro.name}.uniq
    omissions = ["friend", "superuser"]
    (self.authorizations.collect {|auth| auth.authorization_level.name}.uniq ) + role_names - omissions
  end
  
  
  def all_roles
    roles = self.roles.find(:all).compact
    role_names = roles.collect {|ro| ro.name}.uniq
  end  
  
  
  def self.unverified_users
    users = User.find(:all, :conditions => ["religious_affiliation_id is null and verified_at is null and id <> 1"])
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
end
