class Organization < ActiveRecord::Base
  include PublicPersona
  acts_as_tree :order => "name"
  
  belongs_to :status
  belongs_to :organization_type
  belongs_to :organization_size
  belongs_to :featured_topic, :class_name => "Topic"
  belongs_to :default_address, :class_name => "Address"
  belongs_to :coop_group_code
  
  has_one :merchant_account, :dependent => :destroy
  has_one   :bio, :as => :bioable, :dependent => :destroy 

  has_one   :total_view, :as => :entity, :dependent => :destroy
  
  has_many :addresses, :dependent => :destroy
  has_many :authorizations, :as => :scope, :dependent => :destroy
  has_many :authorized_users, :through => :authorizations, :source => :user, :uniq => true do
    def find_all_by_authorization_level_id(authorization_level)
      find :all, :include => :authorizations, :conditions => ["authorizations.authorization_level_id = ?", authorization_level]
    end
  end

  has_many :authorization_levels, :through => :coop_app, :source => :owner

  has_many :classrooms, :dependent => :destroy
  has_many :contents
  has_many :discussions
  has_many :payments
  has_many :topics
  has_many :setting_values, :as => :scope, :dependent => :destroy
  has_many :roles, :as => :scope, :dependent => :destroy
  has_many :page_sections, :dependent => :destroy
  has_many :organization_relationships, :as => :source, :dependent => :destroy
  has_many :blogs, :dependent => :destroy
  has_many :blog_posts, :through => :blogs
  has_many :reported_abuses, :class_name => "ReportedAbuse"
  has_many :metrics
  has_many :users 
  has_many :coop_app_organizations, :dependent => :destroy
  has_many :coop_apps, :through => :coop_app_organizations
  has_many :app_providers, :through => :coop_app_organizations, :uniq => true
  has_many :master_apps, :class_name => 'CoopApp', :foreign_key=>'owner_id'

  has_many :app_discussions, :dependent => :destroy
  

  has_many :folders, :dependent => :destroy
  has_many :folder_positions, :as=>:scope, :dependent => :destroy
    
  has_many :act_benches  
  has_many :act_rel_readings
  has_many :act_questions
  has_many :act_assessments
  has_many :act_submissions
  has_many :act_answers
  has_one :ifa_org_option, :dependent => :destroy
  has_many :act_snapshots
  has_many :ifa_dashboards, :as => :ifa_dashboardable, :order => "period_end asc", :dependent => :destroy
  has_many :ifa_plan_metrics, :as => :entity, :dependent => :destroy
  has_many :ifa_question_logs
  has_many :act_strategy_logs
  has_many :tlt_sessions, :dependent => :destroy 
  has_many :itl_summaries 
  has_many :tlt_survey_questions, :dependent => :destroy
  has_many :tlt_dashboards, :dependent => :destroy
  has_many :tlt_survey_responses
  has_many :tlt_diagnostics
  has_one  :itl_org_option, :dependent => :destroy
  has_many :itl_templates, :dependent => :destroy
  has_many :survey_schedules
  has_one  :time_allocation, :dependent => :destroy

  has_many :ista_cases

  has_one :dle_org_option, :dependent => :destroy
  has_many :organization_dle_metrics, :dependent => :destroy
  has_many :dle_metrics, :through => :organization_dle_metrics, :order => "position" 
  has_many :dle_resources, :dependent => :destroy 
  has_many :dle_cycle_orgs, :dependent => :destroy
  has_many :coop_app_resources, :dependent => :destroy 

  has_many :organization_clients, :dependent=> :destroy
  has_many :clients, :through => :organization_clients, :order => "name" 

  has_many :elt_cases, :dependent => :destroy
  has_many :elt_types, :dependent => :destroy
  has_many :elt_elements, :dependent => :destroy  
  has_one :elt_org_option, :dependent => :destroy
  has_one :elt_provider, :through => :elt_org_option               
  has_many :elt_cycles, :dependent => :destroy
  has_many  :conducted_cycles, :through=> :elt_cases, :source => :elt_cycle, :uniq=>true
  has_many :elt_plan_types, :dependent => :destroy
  has_many :elt_plans, :dependent => :destroy
  has_many :elt_frameworks, :dependent => :destroy
  has_many :elt_standards

  has_one :organization_core_option 

  has_many :users
  
  # validates_confirmation_of 
  validates_presence_of :name

  validates_presence_of :phone
  
  validates_format_of :name, :with => /^[\w\s'-`]+$/, :message => 'not valid',
  :allow_nil => false
  
  validates_format_of :web_site_url, :with => /^((http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?)*$/,
  :message => 'not valid, format http://www.escentpartners.com', :allow_nil => true
  
  validates_format_of :contact_email, :with => /^[\w._%+-]+@[\w.-]+\.[\w]{2,6}$/, :message => 'not valid',
  :allow_nil => false
 
  validates_format_of :contact_name, :with => /^[\w\s'-`]*$/, :message => 'not valid',
  :allow_nil => false
  
  validates_format_of :contact_role, :with => /^[\w\s'-`]*$/, :message => 'not valid',
  :allow_nil => false
  
  validates_format_of :contact_phone, :with => /^\d{3}-{1}\d{3}-{1}\d{4}$/, :message => 'not valid, format XXX-XXX-XXXX',
  :allow_nil => false
  
  validates_format_of :phone, :with => /^\d{3}-{1}\d{3}-{1}\d{4}$/, :message => 'not valid, format XXX-XXX-XXXX',
  :allow_nil => false
  
  has_attached_file :logo,
                    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                    :url => "/system/:attachment/:id/:style/:filename",
                    :styles => { :normal => '315x170' , :small_thumb => '74x40>', :med_thumb => '111x60>', :thumb=>'148x80>' }, :default_style => :normal
  validates_attachment :logo,
                        content_type: {content_type: ['image/gif', 'image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png']}
  validates_with AttachmentSizeValidator, attributes: :logo, less_than: 500.kilobytes
  validate :logo_width

  accepts_nested_attributes_for :organization_relationships


  scope :siblings_of, lambda{|org| { :conditions => ["parent_id AND parent_id = ?", org.parent_id], :order => "name" }}

  scope :of_type, lambda{|org| { :conditions => ["organization_type_id = ? ", org.organization_type_id], :order => "name" }}
  scope :with_type_id, lambda{|type_id| { :conditions => ["organization_type_id = ? ", type_id], :order => "name" }}

  scope :ep_default,   {:conditions =>  ["is_default = ?", true], :order => "created_at DESC"}
  scope :all_parents,   :conditions => ["parent_id IS NULL AND !is_default"]
  scope :active,   :conditions => ["status_id = ?", 1]

  scope :with_user_auth, lambda{|user, auth| {:conditions => ['(authorizations.user_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ? AND status_id = ?)', user.id, 'Organization', auth.id, 1],:include => :authorizations,  :order => 'name'}}

  scope :with_names, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(name REGEXP ? OR name REGEXP ?)'
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}" 
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "name")
    {:conditions => conditions, :order => order_by}
  }

  before_save :before_save_method
  def before_save_method
    if self.default_address.nil? && !self.addresses.empty?
      self.default_address = self.addresses.first
    end
    set_page_section_default
  end

  after_initialize :after_initialize_method
  def after_initialize_method
    if self.status.nil?
      self.status = Status.approved
    end
    if self.organization_type.nil?
      self.organization_type = OrganizationType.affiliate
    end
  end

  DEFAULT_CALL_TO_ACTION = "<p><img src= '\/images\/call_to.jpg' \/><\/p><p>Click [Admin] and edit [Call To Action] module.<\/p>"
  DEFAULT_FOLLOWUP = "<p><img src= '\/images\/followup.jpg' \/><\/p><p>Click [Admin] and edit [WHAT WE HAVE DONE] module.<\/p>"
  
  def set_page_section_default
    if self.content_object_of_page_section("index", "call_to_action").blank?
      self.page_sections << PageSection.new(:page => "index" , :section => "call_to_action" , :body => DEFAULT_CALL_TO_ACTION)
    end
   
    if self.content_object_of_page_section("index", "followup").blank?
      self.page_sections << PageSection.new(:page => "index" , :section => "followup" , :body => DEFAULT_FOLLOWUP)
    end
  end

  def brand_color
    self.style_setting_value_named("Header and Footer Bars")
  end

  def self.highschools
    self.where('organization_type_id = ?', OrganizationType.highschool)
  end

  def self.all_authorization_levels
    AuthorizationLevel.organizations
  end

  def reset
    Organization.find_by_id(self.id) rescue self
  end

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
      
  def actived?
    status == Status.approved
  end

  def active?
    !self.status.nil? && self.status.approved?
  end

  def registerable?
    self.can_register
  end

  def self.registerable
    where("can_register AND status_id = ?", 1).order('name')
  end

  def parent?
    !self.parent.nil?
  end

  def no_parent?
  self.parent.nil?
  end

  def parent_or_self
    self.no_parent? ? self : self.parent
  end

  def all_children
    (self.children + self.children.collect{|child| child.children}).flatten
  end 

  def siblings_same_type
   self.siblings.select{|o| (o.organization_type_id == self.organization_type_id)}
  end

  def active_siblings_same_type
      self.siblings_same_type.select{|o| o.active?}
  end
  def siblings
    self.parent? ? self.parent.children.select{|o|  (o != self)} : []
  end

  def active_siblings
    self.siblings.select{|o| o.active?}
  end

  def all_active_children
    self.all_children.select{|o| o.active?}
  end

  def grade_levels?
    !self.organization_type.grade_levels.empty?
  end

  def non_clients
     (Organization.all.active.where('id!= ? AND !is_default', self.id) - self.clients).order('name')
  end
 
  def client_active?(client)
    !self.organization_clients.active.for_client(client).empty?
  end
  
  def active_clients
     self.organization_clients.active.collect{|c| c.client}
  end
  
  def self.update_all_actived
    update_all "active_status = 'actived'" 
  end
  
  def self.default
    find Organization.ep_default.first
  end
  
  def default?
    self.id == Organization.default.id
  end
  
  def can_be_deleted?
    !self.default? && !self.active?
  end

  def display_contact?
    self.display_contact
  end
    
  def can_be_displayed?(user)
    if user && user.has_authorization_level?("app_superuser")
      display = true
    else
      display = self.actived?
    end
  display
  end

  def register_notify?
    self.organization_core_option ? self.organization_core_option.register_notify : false
  end

  def content_notify?
    self.organization_core_option ? self.organization_core_option.content_notify : false
  end

  def blog_panelists
    self.blogs.collect{|b| b.users}.uniq
  end

  def active_parent_subjects
    self.classrooms.active.collect{|c| c.parent_subject}.compact.uniq.sort_by{|s| s.name} rescue []
  end

  def all_parent_subjects
    self.classrooms.collect{|c| c.parent_subject}.compact.uniq.sort_by{|s| s.name} rescue []
  end

  def unfoldered_parent_subjects
    self.unfoldered_offerings.collect{|c| c.parent_subject}.compact.uniq.sort_by{|s| s.name} rescue []
  end

  def offerings_for_parent_subject(subject_parent)
    self.classrooms.select{|c| c.subject_area_id == subject_parent.id || c.subject_area.parent_id == subject_parent.id }.sort_by{|c| c.course_name.upcase}  rescue []
  end

  def unfoldered_offerings_for_parent_subject(subject_parent)
    self.unfoldered_offerings.select{|c| c.subject_area_id == subject_parent.id || c.subject_area.parent_id == subject_parent.id }.sort_by{|c| c.course_name.upcase}  rescue []
  end
  
  def classrooms_in_subject(subject)
    self.classrooms.active.select{|c| c.subject_area.parent_id == subject.id || c.subject_area_id == subject.id}.sort_by{|c| c.course_name.upcase}  rescue []
  end

  def classroom_count(subject)
    self.classrooms_in_subject(subject).size 
  end
  
  def periods_in_subject_teacher(subject, teacher)
    self.periods_in_subject(subject).select{|p| p.teacher?(teacher)} rescue []
  end

  def periods_in_subject(subject)
    self.classrooms_in_subject(subject).collect{|c| c.classroom_periods}.flatten  rescue [] 
  end
  def period_count(subject)
    self.periods_in_subject(subject).size 
  end

  def teachers_in_subject(subject)
    self.classrooms_in_subject(subject).collect{|c| c.teachers}.flatten.uniq.sort_by{|t| t.last_name}  rescue [] 
  end
  def teacher_count(subject)
    self.teachers_in_subject(subject).size 
  end
  
  def students_in_subject(subject)
    self.classrooms_in_subject(subject).collect{|c| c.students}.flatten  rescue []
  end
  def student_count(subject)
    self.students_in_subject(subject).size 
  end

  def minutes_in_subject(subject)
    self.periods_in_subject(subject).collect{|p| p.week_duration}.sum 
  end

  def itl_comparison_schools
    Organization.of_type(self).select{|org| !org.itl_summaries.empty? && !org.itl_org_option.nil? && org.app_enabled?(CoopApp.ctl) && org != self} rescue []
  end

  def itl_schools
    Organization.of_type(self).select{|org| org.app_enabled?(CoopApp.ctl) } rescue []
  end

  def itl_observation_count
    self.itl_summaries.collect{|s| s.observation_count}.sum rescue 0
  end


#   Apps


  def enabled_app_authorizations
    AuthorizationLevel.app_authorizations(self).select{ |al| app_enabled?(al.coop_app)}.sort_by{|a| a.coop_app.abbrev}
  end

  def superuser_authorizations
    levels = AuthorizationLevel.app_superusers.select{|a| a.owner_org == self}
  end

  def app_settings(app)
    self.coop_app_organizations.for_app(app).first rescue nil
  end

  def appl_owner?(app)
    self.owned_apps.include?(app)
  end
  
  def appl_master?(app)
    app.owner == self
  end
  
  def provider?(app)
    !self.coop_app_organizations.for_app(app).provider.empty? || self.appl_master?(app)
  end
  
  def app_provider(app)
    (self.app_settings(app).nil? || !self.app_settings(app).app_provider ) ? (app.owner ? app.owner : nil) : self.app_settings(app).app_provider
  end

  def provider_app_name(app)
      (self.app_provider(app) && self.app_provider(app).app_settings(app) && self.app_provider(app).app_settings(app).alt_name != '') ? self.app_provider(app).app_settings(app).alt_name : app.name
  end

  def provider_app_abbrev(app)
      (self.app_provider(app) && self.app_provider(app).app_settings(app) && self.app_provider(app).app_settings(app).alt_abbrev != '') ? self.app_provider(app).app_settings(app).alt_abbrev : app.abbrev
  end

  def selected?(app)
    !self.coop_app_organizations.for_app(app).selected.empty?
  end

  def disallowed?(app)
    !self.coop_app_organizations.for_app(app).disallowed.empty?
  end

  def allowed?(app)
    !self.coop_app_organizations.for_app(app).allowed.empty?
  end

  def self.allowed_orgs(app)
    app.coop_app_organizations.allowed.collect{ |co| co.organization}
  end

  def self.disallowed_orgs(app)
    app.coop_app_organizations.disallowed.collect{ |co| co.organization}
  end

  def appl_disallowed?(app)
    self.disallowed_apps.include?(app)
  end

  def appl_selected?(app)
    self.selected_apps.include?(app)
  end

  def appl_discussion_owner?(app)
    !self.coop_app_organizations.for_app(app).discussion_owner.empty?
  end

  def owned_apps
    self.coop_app_organizations.provider.collect{|co| co.coop_app}.uniq.sort_by{|app| [app.abbrev]} rescue []
  end

  def provided_apps
    self.coop_app_organizations.provider.collect{|co| co.coop_app}.uniq.sort_by{|app| [app.abbrev]} rescue []
  end

  def provided_apps_blogable
    self.provided_apps.select{|a| a.is_blogable}
  end
  
  def provided_app_orgs(app, ex_self)
    if ex_self
      CoopAppOrganization.where(["provider_id = ? AND coop_app_id = ? AND organization_id != ? AND is_selected AND is_allowed", self.id, app.id, self.id]).collect{|cao| cao.organization}
    else
      CoopAppOrganization.where(["provider_id = ? AND coop_app_id = ? AND is_selected", self.id, app.id]).collect{|cao| cao.organization}
    end
  end

  def precision_prep_provider_classrooms(subject)
    self.provided_app_orgs(CoopApp.ifa, true).collect{|o| (o.classrooms.empty? ? []: o.classrooms.precision_prep_subject(subject))}.flatten.sort_by{|c| [c.organization.name, c.name]}
  end

  def precision_prep_provider_subject_students(subject)
    self.precision_prep_provider_classrooms(subject).map{|c| c.students}.compact.flatten.uniq.sort_by{|s| [s.organization.name, s.last_name]}
  end

  def precision_prep_provider_students
    self.provided_app_orgs(CoopApp.ifa, true).collect{|o| o.classrooms.precision_prep_students}.flatten.sort_by{|s| [s.organization.name, s.last_name]}
  end

  def provided_app_org_types(app, ex_self)
    self.provided_app_orgs(app, ex_self).collect{|o| o.organization_type}.compact.uniq
  end

  def all_owned_apps
    (self.owned_apps + self.master_apps).uniq.sort_by{|app| [app.abbrev]} rescue []
  end

  def app_master?(app)
    app.owner_id == self.id
  end

  def selected_apps
    self.coop_app_organizations.selected.collect{|co| co.coop_app}.sort_by{|app| [app.abbrev]} rescue []
  end

  def allowed_apps
    self.coop_app_organizations.allowed.collect{|co| co.coop_app}.sort_by{|app| [app.abbrev]} rescue []
  end

  def disallowed_apps
    self.coop_app_organizations.disallowed.collect{|co| co.coop_app}.sort_by{|app| [app.abbrev]} rescue []
  end
    
  def enabled_apps
    self.coop_app_organizations.enabled.collect{|co| co.coop_app}.select{|app| app.available?}.sort_by{|app| [app.abbrev]}
  end

  def selectable_apps
    (CoopApp.available - self.disallowed_apps).select{|a| a != CoopApp.core}.sort_by{|app| [app.abbrev]}
  end
    
  def ifa_enabled?
    self.app_enabled?(CoopApp.ifa)
  end

  def ifa_plannable?
    self.ifa_enabled?  && self.ifa_org_option  && self.ifa_org_option.is_plannable
  end
  
  def app_enabled?(app)
    self.enabled_apps.include?(app)
  end

  def app_id_enabled?(app)
    !self.coop_app_organizations.select{|ca| ca.coop_app_id == app.id}.empty?
  end

  def resources_for_app(app)
    self.coop_app_resources.for_app(app).empty? ? [] : self.coop_app_resources.for_app(app).by_position.collect{|ar| ar.content}.uniq
  end

  def elt_framework?
    self.elt_org_option && self.elt_org_option.elt_framework
  end

  def set_framework(framework)
    self.elt_org_option.update_attributes(:elt_framework_id => framework.nil? ? nil : framework.id)
  end

  def initial_framework
    self.elt_frameworks.empty? ? self.set_framework(nil) : self.set_framework(self.elt_frameworks.first)
  end

  def used_frameworks
    self.elt_cases.collect{|c| c.framework}.compact.uniq
  end

  def current_cycle_framework
    self.elt_org_option.elt_cycle.elt_framework rescue nil
  end

  def active_frameworks
    self.elt_types.active.collect{|a| a.elt_framework}.compact.uniq
  end

  def elt_framework
    self.elt_framework? ? self.elt_org_option.elt_framework : nil
  end

  def elt_cycle_activity_cases(cycle, activity)
  #   EltCase.find(:all, :conditions => ["organization_id = ? AND elt_cycle_id = ? AND elt_type_id = ?", self.id, cycle.id, activity.id])
    EltCase.where("organization_id = ? AND elt_cycle_id = ? AND elt_type_id = ?", self.id, cycle.id, activity.id)
  end

  def elt_cycle_activity_rubrics(cycle, activity)
    self.elt_cycle_activity_cases(cycle, activity).each do

    end
  end

  def elt_cycle_cases(cycle)
 #    EltCase.find(:all, :conditions => ["organization_id = ? AND elt_cycle_id = ?", self.id, cycle.id])
     EltCase.where("organization_id = ? AND elt_cycle_id = ?", self.id, cycle.id)
  end

  def elt_cycle_activities(cycle)
     self.elt_cycle_cases(cycle).collect{|c| c.elt_type}.compact.uniq.sort_by{|a| a.position} 
  end

  def elt_case_activities
    self.elt_cases.collect{|c| c.elt_type}.compact.uniq.sort_by{|a| a.position}
  end

  def elt_case_activities_finalized
    self.elt_cases.final.collect{|c| c.elt_type}.compact.uniq.sort_by{|a| a.position}
  end

  def final_case_activities(framework)
    self.elt_cases.final.for_framework(framework).collect{|c| c.elt_type}.compact.uniq.sort_by{|a| a.position}
  end

  def elt_case_activities_reportable
    self.elt_cases.final.collect{|c| c.elt_type}.compact.uniq.select{|a| a.reportable?}.sort_by{|a| a.position}
  end

  def final_case_activities_reportable(framework)
    self.elt_cases.final.for_framework(framework).collect{|c| c.elt_type}.compact.uniq.select{|a| a.reportable?}.sort_by{|a| a.position}
  end

  def elt_cycle_plan(cycle)
    self.elt_plans.for_cycle(cycle).first rescue nil
  end
  
  def elt_action_plan(cycle)
    self.elt_cycle_plan(cycle)
  end
  
  def elt_all_cycles(provider)
    self.elt_cases.for_provider(provider).all.collect{|c| c.elt_cycle}.uniq.sort{|a,b| b.begin_date <=> a.begin_date }
  end


  def elt_active_cycles(provider)
    self.elt_all_cycles(provider).select{|c| c.active?}
  end

  def elt_summarized_cycles
    EltCycleSummary.for_provider(self).collect{|cs| cs.elt_cycle}.compact.uniq.sort{|a,b| b.begin_date <=> a.begin_date}
  end

  def elt_activities
    self.elt_types.by_position
  end

  def elt_master_activity
    self.elt_master_activities.first rescue nil
  end

  def elt_master_activities
    self.elt_types.active.masters
  end

  def elt_provider
   self.app_settings(CoopApp.elt).app_provider ? self.app_settings(CoopApp.elt).app_provider : CoopApp.elt.app_providers.first
#    self.elt_org_option.elt_provider rescue nil
  end
  
  def elt_evidences_for_indicator(ind)
    self.elt_cases.collect{|c| c.elt_case_indicators.for_indicator(ind)}.flatten.compact
  end

  def all_elt_findings
    self.elt_cases.collect{|c| c.elt_case_indicators}.flatten.compact
  end

  def all_elt_images
    self.elt_cases.collect{|c| c.elt_case_evidences}.flatten.compact
  end

  def cycle_images(elt_case, option = {})
   unless elt_case.elt_cycle.nil?
    images = self.elt_cases.for_cycle(elt_case.elt_cycle).collect{|c| c.elt_case_evidences}.flatten.compact
    option[:include_case] == true ? images : images.select{|i| i.elt_case_id != elt_case.id}
   else
     []
   end
  end

  def elt_evidences_for_cycle_indicator(cycle,ind)
    self.elt_cases.for_cycle(cycle).collect{|c| c.elt_case_indicators.for_indicator(ind)}.flatten.compact
  end

  def elt_final_evidences_for_indicator(ind)
    self.elt_cases.final.collect{|c| c.elt_case_indicators.for_indicator(ind)}.flatten.compact
  end

  def active_elt_cycle
    self.elt_org_option.elt_cycle rescue nil
  end

  def past_elt_cycles
    self.elt_org_option.elt_cycle rescue nil
  end
  
  def last_elt_submitted
    self.elt_cases.submitted.sort_by{|c| c.submit_date}.last
  end

  def set_org_options(app, create)
    if app.ifa?
      create ? self.ifa_set_org_options : self.ifa_remove_org_options
    end    
    if app.ctl? && create
      self.itl_set_org_options
    end
    if app.pd? && create
      self.dle_set_org_options 
    end    
    if app.elt?  && create
      unless self.elt_org_option
        self.reset_org_option(app, create)
      end
    end  
  end
     
  def ifa_set_org_options
    unless self.ifa_org_option
      options = IfaOrgOption.new
      options.organization_id = self.id
      options.days_til_repeat = 0
      options.sms_calc_cycle = 30
      options.sms_h_threshold = 0.75
      options.pct_correct_red = 60
      options.pct_correct_green = 80
      options.months_for_questions = 3
      options.begin_school_year = Date.today
      self.ifa_org_option = options
      self.ifa_org_option.act_masters<<ActMaster.default_std
      self.ifa_org_option.ifa_org_option_act_masters.first.update_attributes(:is_default => true)
     end
  end   
 
  def itl_set_org_options
    unless self.itl_org_option
      options = ItlOrgOption.new
      options.organization_id = self.id
      options.stat_window = 6
      options.log_display_count = 6
      options.is_concurrent = false
      options.is_belt_ranking = false
      options.is_thresholds = false
      self.itl_org_option = options
      self.itl_org_option.app_methods<<AppMethod.rs.first
     end
  end 
 
 def dle_set_org_options
    unless self.dle_org_option
      options = DleOrgOption.new
      options.organization_id = self.id
      options.is_coach_enabled = false
      self.dle_org_option = options
     end
    unless self.dle_cycle_orgs.empty?
      self.dle_cycle_orgs.destroy_all
    end
    DleCycle.all_by_stage.each do |s|
        stage_pref = self.dle_cycle_orgs.new
        stage_pref.dle_cycle_id = s.id
        stage_pref.tlt_survey_type_id = s.tlt_survey_type_id
        stage_pref.is_output = s.is_output
        stage_pref.output_label = s.output_label
        stage_pref.is_targets = s.is_targets
        stage_pref.is_actual = s.is_actual
        stage_pref.is_attachable = s.is_attachable
        stage_pref.attach_label = s.attach_label
        stage_pref.save
    end
  end 

  def elt_set_org_options
    unless self.elt_org_option
      self.elt_reset_org_option
     end
  end

  def reset_org_option(app, on)
    if app.elt?
      if self.elt_org_option && !on
        self.elt_org_option.destroy
      end
      if self.elt_org_option.nil? && on
        options = EltOrgOption.new
        options.organization_id = self.id
        options.owner_org_id = CoopApp.elt.owner.id
        options.elt_cycle_id = nil
        options.elt_framework_id = nil
        self.elt_org_option = options
      end
    end
    if app.ifa?
      if self.ifa_org_option && !on
        self.ifa_org_option.destroy
      end
      if self.ifa_org_option.nil? && on
        ifa_set_org_options
      end
    end
  end
    
  def ifa_remove_org_options
    if self.ifa_org_option
      self.ifa_org_option.destroy rescue nil
      self.classrooms.each do |c|
        c.ifa_classroom_option.destroy rescue nil
      end
     end
  end

  def last_ifa_dashboard(subject)
    self.ifa_dashboards.for_subject(subject).empty? ? nil :
        self.ifa_dashboards.for_subject(subject).last
  end

  def ifa_standards
    standards = []
    if self.ifa_org_option
      standards = self.ifa_org_option.act_masters
    end
    standards
  end

  def master_standard
    self.ifa_org_option && self.ifa_org_option.master_standard ? self.ifa_org_option.master_standard : ActMaster.default
  end

  def master_standard?
    self.master_standard.nil? ? false : true
  end

  def precision_prep_students(subject)
    self.classrooms.precision_prep_subject(subject).collect{|c| c.students}.flatten.compact.uniq.sort_by{|s| s.last_name}
  end

  def ifa_students(subject)
    self.classrooms.ifa_enabled_subject(subject).collect{|c| c.students}.flatten.compact.uniq.sort_by{|s| s.last_name}
  end

  def current_ifa_teachers
    self.classrooms.active.ifa_on.map{|c| c.teachers}.flatten.compact.uniq.sort_by{|t| t.last_name}
  end

  def knowledge_strands
    self.ifa_standards.collect{|s| s.act_standards}.flatten
  end

  def knowledge_strands_subject(subject)
    self.knowledge_strands.select{|s| s.active? && s.act_subject_id == subject.id}
  end

  def knowledge_levels
    self.ifa_standards.collect{|s| s.act_score_ranges.no_na}.flatten
  end

  def knowledge_levels_subject(subject)
    self.knowledge_levels.select{|s| s.active? && s.act_subject_id == subject.id}
  end

  def elt_remove_org_options
    if self.elt_org_option
      self.elt_org_option.destroy rescue nil
    end
  end  

  def subjects_with_tlt_sessions
    self.itl_summaries.collect{|s| s.subject_area}.uniq.sort_by{|s| s.name}
  end

  def subjects_with_tlt_sessions_since(yr_mnth_day)
    self.itl_summaries.where('yr_mnth_of >= ?', yr_mnth_day.beginning_of_month).collect{|s| s.subject_area}.compact.uniq.sort_by{|s| s.name}
  end

  def itl_summaries_for_month_subject(subj, month)
       if subj
         # ItlSummary.find(:all, :conditions => ["organization_id = ? AND subject_area_id = ? AND yr_mnth_of = ? ", self.id, subj.id, month.beginning_of_month])
         self.itl_summaries.for_subject(subj).for_month( month.beginning_of_month)
       else
         # ItlSummary.find(:all, :conditions => ["organization_id = ? AND yr_mnth_of = ? ", self.id,  month.beginning_of_month])
         self.itl_summaries.for_month(month.beginning_of_month)
       end
  end

  def itl_summaries_since_date_subject(subj, month)
       if subj
         # ItlSummary.find(:all, :conditions => ["organization_id = ? AND subject_area_id = ? AND yr_mnth_of >= ? ", self.id, subj.id, month.beginning_of_month])
         self.itl_summaries.for_subject(subj).since_date(month.beginning_of_month)
       else
         # ItlSummary.find(:all, :conditions => ["organization_id = ? AND yr_mnth_of >= ? ", self.id, month.beginning_of_month])
         self.itl_summaries.since_date(month.beginning_of_month)
       end
  end
  
  def itl_summaries_between_dates_subject(subj, month1, month2)
       if subj
         # ItlSummary.find(:all, :conditions => ["organization_id = ? AND subject_area_id = ?  AND yr_mnth_of >= ? AND yr_mnth_of <= ?", self.id, subj.id, month1.beginning_of_month, month2.end_of_month])
         self.itl_summaries.for_subject(subj).between_dates(month1.beginning_of_month, month2.beginning_of_month)
       else
         # ItlSummary.find(:all, :conditions => ["organization_id = ? AND yr_mnth_of >= ? AND yr_mnth_of <= ?", self.id, month1.beginning_of_month, month2.end_of_month])
         self.itl_summaries.between_dates(month1.beginning_of_month, month2.beginning_of_month)
       end
  end

  def itl_summaries_between_dates_subject_belt(subj, month1, month2, belt)
       if subj
         self.itl_summaries.for_subject(subj).between_dates(month1.beginning_of_month, month2.beginning_of_month).select{|s| !s.itl_belt_rank.nil? && s.itl_belt_rank.rank_score >= belt.rank_score}
       else
         self.itl_summaries.between_dates(month1.beginning_of_month, month2.beginning_of_month).select{|s| !s.itl_belt_rank.nil? && s.itl_belt_rank.rank_score >= belt.rank_score}
       end
  end
  
  def itl_remove_org_options
    if self.itl_org_option
      self.itl_org_option.destroy rescue nil
    end
  end 

  def itl_belt_ranking?
    self.itl_org_option.is_belt_ranking
  end

  def itl_thresholds?
    self.itl_org_option.is_thresholds
  end

  def default_template
    template = self.itl_templates.enabled.default.first rescue nil
  end

  def useable_default_template
    (self.default_template && self.default_template.useable?) ? self.default_template : nil
  end

  def useable_itl_templates
    templates = []
    self.itl_templates.enabled.each do |template|
      useable = true
      template.app_methods.each do |method|
        unless self.itl_org_option.app_methods.include?(method)
          useable = false
        end
      end
      if useable
        templates<<template
      end
    end
    templates
  end

  def dle_remove_org_options
    if self.dle_org_option
      self.dle_org_option.destroy rescue nil
    end
    unless self.dle_cycle_orgs.empty?
      self.dle_cycle_orgs.destroy_all
    end
  end 

  
  def prepare_regexps
    return Regexp.new("update_(style_setting|search_setting)_value_named"), 
    Regexp.new("(style_setting|search_setting)_value_named"),
    Regexp.new("(content_partners|cause_partners)")
  end
  
   def respond_to?(method, foo = nil)
     method_name = method.to_s
     updater_re, getter_re, partner_re = self.prepare_regexps
     if method_name.match(updater_re) || method_name.match(getter_re)
       true
     else
       super
     end
   end

  def method_missing(method, *args)
    method_name = method.to_s
    
    updater_re, getter_re, partner_re = self.prepare_regexps
    if (match_data = method_name.match(updater_re))
      setting_name = args.first
      value = args.second
      setting_value = self.setting_values.send(match_data[1].tableize).find_or_create_by_setting_id(Object.const_get(match_data[1].classify).find_by_name(setting_name).id) 
      setting_value.update_attributes! :value => value
    elsif (match_data = method_name.match(getter_re))
      setting_name = args.first
      setting_value = self.setting_values.send(match_data[1].tableize).where('settings.name = ?', setting_name).first
      setting_value ? setting_value.value : Object.const_get(match_data[1].classify).find_by_name(setting_name).default_value
    elsif (match_data = method_name.match(partner_re))
      if self.instance_variable_get("@#{match_data[1]}")
        self.instance_variable_get("@#{match_data[1]}")
      end
    else
      super
    end
  end

  
  def content_types
    self.contents.collect{|c| c.content_resource_type}.flatten.compact.uniq.sort_by{|t| t.name}
  end
  
  def content_object_of_page_section(page, section)
    page_section = self.page_sections.find_by_page_and_section(page, section)
    page_section ? page_section.body : ""
  end

  def featured_lus
    self.active_offerings.empty? ? [] : self.classrooms.active.collect{|c| c.topics.active}.flatten
  end

  def active_offerings
    self.classrooms.active
  end

  def closed_offerings
    self.classrooms.closed.active
  end

  def opened_offerings
    self.classrooms.opened.active
  end

  def copy_featured_topic_from(organization, options={})
    self.featured_topic = organization.featured_topic.clone
    self.featured_topic.organization = self
    self.featured_topic.save
    self.featured_topic.contents = organization.featured_topic.contents
    self.featured_topic.save
    self.save
  end

 def short_name
  if self.alt_short_name.nil? || self.alt_short_name.empty? then
   if self.organization_type.name == "High School" then 
     self.name.sub(' High School','')
     elsif self.organization_type.name == "Elementary School" then 
        self.name.sub(' Elementary School','')
        elsif self.organization_type.name == "Middle School" then 
          self.name.sub(' Middle School','')
            elsif self.organization_type.name == "College or University" then 
              self.name.sub(' University','').sub('College','')
               else self.name 
                 end
  else
    self.alt_short_name
  end
 end
 
  def medium_name
   if self.organization_type.name == "High School" then 
     self.name.sub(' High School',' HS')
     elsif self.organization_type.name == "Elementary School" then 
        self.name.sub(' Elementary School',' ES')
        elsif self.organization_type.name == "Middle School" then 
          self.name.sub(' Middle School',' MS')
            elsif self.organization_type.name == "College or University" then 
              self.name.sub(' University',' Univ.').sub('College',' Col.')
               else self.name 
                 end
 end

  def nickname
   (self.nick_name.empty? || self.nick_name.nil?) ? self.short_name : self.nick_name
  end
 
 def learning_units
   self.classrooms.map{|c| c.topics.active}.compact.flatten
 end

  def self_resources_used_by_others_not_uniq
     classrooms = self.classrooms.active
     topics = classrooms.collect{|c| c.topics}.flatten
     used_resources = topics.collect{|t| t.contents}.flatten
     self_resources = self.contents
     resources = []
     used_resources.each do |r|
     if self_resources.include?(r) then
         resources << r
         else
       end
    end
   resources
  end

  def self_resources_used_by_self_not_uniq
     classrooms = self.classrooms.active
     topics = classrooms.collect{|c| c.topics}.flatten
     used_resources = topics.collect{|t| t.contents}.flatten
     self_resources = self.contents
     resources = []
     used_resources.each do |r|
     if self_resources.include?(r) then
         resources << r
         else
       end
    end
   resources
  end
  
  def others_resources_used_by_self_not_uniq
     classrooms = self.classrooms.active
     topics = classrooms.collect{|c| c.topics}.flatten
     used_resources = topics.collect{|t| t.contents}.flatten
     self_resources = self.contents
     resources = []
     used_resources.each do |r|
     if !self_resources.include?(r) then
         resources << r
         else
       end
    end
   resources
  end

  def school_begin_date
    start_date = false
    if self.ifa_org_option
        year_delta = self.ifa_org_option.begin_school_year ? ((Date.today.to_time - self.ifa_org_option.begin_school_year.to_time)/(60*60*24*365)).to_i : 0
        start_date = year_delta <= 0 ? (self.ifa_org_option.begin_school_year + year_delta.years) : self.ifa_org_option.begin_school_year
    end
    start_date
  end


  def uniq_classroom_subjects
    self.classrooms.active.collect{|clsrm| clsrm.subject_area}.compact.uniq.sort_by{|s| s.name}
  end

  def classrooms_on_subject(subject)
#   Classroom.active.find(:all, :conditions => ["organization_id = ? AND subject_areas.name =?", self.id, subject], :include => :subject_area, :order => "course_name ASC")
    self.classrooms.on_subject(subject).active
  end

  def resources_on_subject(subject)
#    Content.active.find(:all, :conditions => ["organization_id =? AND subject_areas.name =?", self.id, subject], :include => :subject_area,:order => "created_at DESC")
    self.contents.on_subject(subject).active
  end
  
  def unfoldered_offerings
    self.classrooms.select{|c| !c.folder }.sort_by{ |o| o.subject_area.name}
  end
  
  def unfoldered_active_offerings
    self.classrooms.active.select{|c| !c.folder && !c.subject_area.nil? }.sort_by{ |o| o.subject_area.name}
  end
  
  def foldered_offerings
    self.classrooms.select{|c| c.folder }.sort_by{ |o| o.folder.name}
  end
  
  def foldered_active_offerings
    self.classrooms.active.select{|c| c.folder }.sort_by{ |o| o.folder.name}
  end
     
  def offerings_in_folder(folder)
    self.classrooms.select{|c| c.folder == folder}
  end
   
  def active_offerings_in_folder(folder)
    self.classrooms.active.select{|c| c.folder == folder}
  end
  
  def offering_folders
    self.classrooms.collect{|o| o.folder}.flatten.compact.uniq.sort_by{|f| f.position(self.id, self.class.to_s)}
  end

  def active_offering_folders
    self.classrooms.active.collect{|o| o.folder}.flatten.compact.uniq.sort_by{|f| f.position(self.id, self.class.to_s)}
  end

  def active_featured_topic_folders
    self.classrooms.active.select{|c| c.featured_topic}.collect{|o| o.folder}.flatten.compact.uniq.sort_by{|f| f.position(self.id, self.class.to_s)}
  end

  def position_for_folder(folder)
    (self.folder_positions && !self.folder_positions.for_folder(folder).empty?) ? self.folder_positions.for_folder(folder).first.position : 0
  end

  def all_folder_positions_for_app(app)
    self.folder_positions.all.select{|fp| fp.folder.coop_app_id == app.id}
  end

  def populated_offering_folders_app(app)
    self.all_folder_positions_for_app(app).collect{|fp| fp.folder}.flatten.compact
  end

  def unpopulated_offering_folders_app(app)
    self.folders.for_app(app) - self.populated_offering_folders_app(app)
  end
  
  def last_folder_position_for_app(app)
    self.all_folder_positions_for_app(app).last.position
  end


  def org_followers 
      fol_auths = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.friend, self).collect{|a| a.user}
  end

  def friends
    self.org_followers
  end
  
  def administrators 
      admins = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.administrator, self).collect{|a| a.user}
  end

  def administrator_list
    unless self.administrators.empty?
      self.administrators.sort_by{|u| u.last_name}.collect{|t| t.last_name}.uniq.join(", ")
    else
      ""
    end
  end

  def administrator_email_list
    unless self.administrators.empty?
      self.administrators.sort_by{|u| u.last_name}.collect{|t| t.preferred_email}.compact.uniq.join(", ")
    else
      ""
    end
  end
  def bloggers 
      bloggers = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.blogger, self).collect{|a| a.user}.sort_by{|u| u.last_name}
  end

  def blog_admins 
    Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.blog_admin, self).collect{|a| a.user}
  end

  def blogger_list
    unless self.bloggers.empty?
      self.bloggers.sort_by{|u| u.last_name}.collect{|t| t.last_name}.uniq.join(", ")
    else
      ""
    end
  end

  def teachers 
      teachers = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.teacher, self).collect{|a| a.user}
  end

  def teacher_list
    unless self.teachers.empty?
      self.teachers.sort_by{|u| u.last_name}.collect{|t| t.last_name}.uniq.join(", ")
    else
      ""
    end
  end

  def staff_consultants 
      consultants = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.consultant, self).collect{|a| a.user}
  end

  def consultants_for_client(client) 
      self.organization_clients.for_client(client).first.consultants
  end

  def consultant_list_for_client(client)
      self.consultants_for_client(client).collect{|t| t.last_name}.uniq.join(", ")
  end

  def consultant_assignment(client, consultant)
      self.organization_clients.for_client(client).first.client_assignments.for_consultant(consultant) rescue nil
  end
  
  def content_admins 
      content_admins = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.content_administrator, self).collect{|a| a.user}
  end
  
  def cm_admins 
      cm_admins = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.cm_admin, self).collect{|a| a.user}
  end
  
  def cm_kms 
      kms = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.km, self).collect{|a| a.user}
  end

  def elt_admins 
      elt_admins = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.elt_admin, self).collect{|a| a.user}
  end
  
  def elt_team 
      elt_team = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.elt_team, self).collect{|a| a.user}
  end

  def elt_reviewers 
      elt_reviewers = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.elt_reviewer, self).collect{|a| a.user}
  end
  
  def active_pd_plan_count
    self.teachers.select{|t| t.dle_plan_active?}.size
  end

  def itl_observers 
      trackers = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Organization', AuthorizationLevel.itl_observer, self).collect{|a| a.user}
  end

  def itl_observer_list
    unless self.itl_observers.empty?
      self.itl_observers.sort_by{|u| u.last_name}.collect{|t| t.last_name}.uniq.join(", ")
    else
      ""
    end
  end

  def admins_for_app(app)
   self.authorizations.for_level(AuthorizationLevel.app_administrator(app)).collect{ |a| a.user}.compact.uniq
  end
  
  def admin_list_for_app(app)
    self.admins_for_app(app).sort_by{|u| u.last_name}.collect{|t| t.last_name}.uniq.join(", ")
  end

  def itl_admins
    self.authorizations.for_level(AuthorizationLevel.app_administrator(CoopApp.itl)).collect{ |a| a.user}.compact.uniq
  end

  def itl_admin_list
    unless self.itl_admins.empty?
      self.itl_admins.sort_by{|u| u.last_name}.collect{|t| t.last_name}.uniq.join(", ")
    else
      ""
    end
  end

  def pd_admins
    self.authorizations.for_level(AuthorizationLevel.app_administrator(CoopApp.pd)).collect{ |a| a.user}.compact.uniq
  end

  def pd_admin_list
    unless self.pd_admins.empty?
      self.pd_admins.sort_by{|u| u.last_name}.collect{|t| t.last_name}.uniq.join(", ")
    else
      ""
    end
  end

  def ifa_admins
    self.authorizations.for_level(AuthorizationLevel.app_administrator(CoopApp.ifa)).collect{ |a| a.user}.compact.uniq
  end

  def ifa_admin_list
    unless self.ifa_admins.empty?
      self.ifa_admins.sort_by{|u| u.last_name}.collect{|t| t.last_name}.uniq.join(", ")
    else
      ""
    end
  end

  def ifa_admin_email_list
    unless self.ifa_admins.empty?
      self.ifa_admins.sort_by{|u| u.last_name}.collect{|t| t.preferred_email}.uniq.join(", ")
    else
      ""
    end
  end

  def ifa_admin_full_names
    unless self.ifa_admins.empty?
      self.ifa_admins.sort_by{|u| u.last_name}.collect{|t| t.full_name}.uniq.join(", ")
    else
      ""
    end
  end

  def coaches
    self.authorizations.for_level(AuthorizationLevel.app_observer(CoopApp.ctl)).collect{ |a| a.user}.compact.uniq
  end
  def coach_list
    unless self.coaches.empty?
      self.coaches.sort_by{|u| u.last_name}.collect{|t| t.last_name}.uniq.join(", ")
    else
      ""
    end
  end

  def current_ifa_students
    self.classrooms.active.ifa_on.collect{|c| c.students}.flatten.compact.uniq.sort_by{|u| u.last_name}
  end

  def current_ifa_students_with_guardian
    self.current_students.select{|s| !s.guardians.empty?}
  end

  def current_students 
      self.classrooms.active.collect{|c| c.students}.flatten.uniq
  end

  def current_students_with_guardian
    self.current_students.select{|s| !s.guardians.empty?}
  end

  def students_beginning_with(letter)
      self.current_students.select{|u| u.last_name[0].chr.upcase == letter.upcase}
  end
 
 
  def partner_organizations
    self.friends_of_org.collect{ |u| u.organization}.compact.uniq
  end

  def friends_of_org
    self.authorizations.for_level(AuthorizationLevel.app_friend(CoopApp.core)).collect{|a| a.user}.compact.uniq.sort_by{|u| u.last_name}
  end

  def home_users
   self.users
  end

  def assigned_teachers
    self.classrooms.collect{|c| c.classroom_periods}.flatten.collect{|p| p.classroom_periods_users.teachers}.flatten.collect{|u| u.users}.flatten.uniq
  end
  
  def remove_organization_relationship(organization_relationship)
    unless organization_relationship.is_a? OrganizationRelationship
      organization_relationship = self.organization_relationships.find(organization_relationship) rescue nil
    end
    if organization_relationship
      organization_relationship.destroy
    end
  end

  def clear_featured_blog
    self.blogs.featured.first.update_attribute("feature", false) rescue nil
  end

   def pov_header_blog
    blog = BlogType.pov_header.first.blogs.select{|b| b.organization_id == self.id && b.feature}.first rescue nil
  end

  def panel_blogs
    self.blogs.active.for_app(CoopApp.blog) rescue []
  end

  def panel_blog_featured
    self.blogs.active.featured.for_app(CoopApp.blog).first rescue nil
  end

  def panel_blogs_notfeatured
    self.blogs.active.not_featured.for_app(CoopApp.blog) rescue []
  end

  def pov_blogs
    blogs = BlogType.pov.first.blogs.select{|b| b.organization_id == self.id} rescue []
  end

  def active_nonfeatured_povs
    blogs = BlogType.pov.first.blogs.active.not_featured.select{|b| b.organization_id == self.id} rescue []
  end

 
  def pov_featured_blog
    blog = BlogType.pov.first.blogs.select{|b| b.organization_id == self.id && b.feature}.first rescue nil
  end
  
  def who_we_are
    BlogType.org.first.blogs.active.select{|b| b.organization_id == self.id} rescue []
  end

  def who_we_are_featured
    BlogType.org.first.blogs.featured.select{|b| b.organization_id == self.id}.first rescue nil
  end

  def our_offerings
    BlogType.our_offering.first.blogs.select{|b| b.organization_id == self.id} rescue []
  end

  def our_offerings_featured
    BlogType.our_offering.first.blogs.featured.select{|b| b.organization_id == self.id}.first rescue nil
  end

  def active_nonfeatured_offerings
    blogs = BlogType.our_offering.first.blogs.active.not_featured.select{|b| b.organization_id == self.id} rescue []
  end

  def bios
    BlogType.bio.first.blogs.active.select{|b| b.organization_id == self.id} rescue []
  end

  def bios_featured
    BlogType.bio.first.blogs.featured.select{|b| b.organization_id == self.id}.first rescue nil
  end

  def assets
    BlogType.asset.first.blogs.select{|b| b.organization_id == self.id} rescue []
  end

  def assets_featured
    BlogType.asset.first.blogs.featured.select{|b| b.organization_id == self.id}.first rescue nil
  end

  def active_nonfeatured_assets
    blogs = BlogType.asset.first.blogs.active.not_featured.select{|b| b.organization_id == self.id} rescue []
  end

  def about_us
    BlogType.about_us.first.blogs.active.select{|b| b.organization_id == self.id} rescue []
  end

  def about_us_featured
    BlogType.about_us.first.blogs.featured.select{|b| b.organization_id == self.id}.first rescue nil
  end
  
  def projects
    BlogType.project.first.blogs.active.select{|b| b.organization_id == self.id} rescue []
  end

  def projects_featured
    BlogType.project.first.blogs.featured.select{|b| b.organization_id == self.id}.first rescue nil
  end
  
  def instructions
    BlogType.instruction.first.blogs.select{|b| b.organization_id == self.id} rescue []
  end

  def instructions_featured
    BlogType.instruction.first.blogs.featured.select{|b| b.organization_id == self.id}.first rescue nil
  end

  def testimonials
    BlogType.testimonial.first.blogs.active.select{|b| b.organization_id == self.id} rescue []
  end

  def testimonials_active
    BlogType.testimonial.first.blogs.active.select{|b| b.organization_id == self.id} rescue []
  end

  def sequence_blogs
  blogs = self.blogs.sort_by{|b|b.position}
  blogs.each_with_index do |blog,idx|
    blog.update_attributes(:position=>idx+1)
    end
  end
 
  def sequence_blogs_of_type(blog_type) 
  blogs = self.blogs.for_type(blog_type).sort_by{|b|b.position}
  blogs.each_with_index do |blog,idx|
    blog.update_attributes(:position=>idx+1)
    end
  end 

  def conversation_for?(app)
    if CoopApp.itl == app
      self.itl_org_option.is_conversations
    else
      false
    end
  end
  
  #Daniel temp methods
  def discussion_abuses
    discussions = []
    
    self.discussions.each do |discussion|
      discussions << discussion unless discussion.reported_abuses.empty?
    end        
    
    discussions
  end
  
  def content_abuses
    
  end
  
  # Update style settings at once, added by victor
  def update_style_settings(params)
    style_settings = self.setting_values.style_settings.collect{|style| style.setting.name}
    style_settings.each do |style|
      self.update_style_setting_value_named(style, params[style]) 
    end
  end

  def new_setting!(setting)
    new_setting = self.setting_value.new
    new_setting.setting_id = setting.id
    new_setting.value = setting.default_value
    new_setting.save
  end

  #restore style settings to the system default, also used to during org registration
  def set_default_style_settings
    if !self.setting_values.empty?
      self.setting_values.style_settings.delete_all
    end
    
    default_settings = Setting.find_all_by_group_name("Colors")

    default_settings.each do |setting| 
      style = self.setting_values.style_settings.create()
      style.setting_id = setting.id
      style.value = setting.default_value
      style.save
    end 
  end

  def logo_missing?
    self.logo.url.split("/").last == "missing.png"
  end
  
  private

  def logo_width
    required_width  = 300
    if logo.queued_for_write[:original]
      dimensions = Paperclip::Geometry.from_file(logo.queued_for_write[:original].path)
      errors.add(:logo, "Width can't be greater than #{required_width}") unless dimensions.width <= required_width
    end
  end


end
