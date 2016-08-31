class CoopApp < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :owner, :class_name=>'Organization', :foreign_key=>'owner_id'


  has_one   :total_view, :as => :entity, :dependent => :destroy

  has_many :coop_app_rates, :dependent => :destroy
  has_many :coop_app_organizations, :dependent => :destroy
  has_many :organizations, :through => :coop_app_organizations
  has_many :app_providers, :through => :coop_app_organizations, :uniq => true

  has_many :tlt_survey_audiences, :dependent => :destroy
  has_many :tlt_survey_questions, :dependent => :destroy
  has_many :tlt_survey_types, :dependent => :destroy
  has_many :blogs, :dependent => :destroy
  has_many :authorization_levels

  has_many :authorizations, :as => :scope, :dependent => :destroy
  has_many :authorized_users, :through => :authorizations, :source => :user, :uniq => true do
    def find_all_by_authorization_level_id(authorization_level)
      find :all, :include => :authorizations, :conditions => ["authorizations.authorization_level_id = ?", authorization_level]
    end
  end
 
  has_many   :survey_schedules, :as => :entity, :dependent => :destroy  
  has_many   :coop_app_resources, :dependent => :destroy  

  has_many :coop_app_content_resource_types, :dependent => :destroy
  has_many :content_resource_types, :through => :coop_app_content_resource_types
  has_many :coop_app_resources_subjects, :dependent => :destroy
  has_many :subject_areas, :through => :coop_app_resources_subjects

  has_many :app_methods, :dependent => :destroy
  has_many :app_discussions, :dependent => :destroy

  has_many :folders, :dependent => :destroy
   
  scope :blogs,  :conditions => ["abbrev = ? ", "BLOGS"]
  scope :itls,  :conditions => ["abbrev = ? ", "CTL"]
  scope :ctls,  :conditions => ["abbrev = ? ", "CTL"]
  scope :classrooms,  :conditions => ["abbrev = ? ", "CLASSROOM"]
  scope :ifas,  :conditions => ["abbrev = ? ", "IFA"]
  scope :available,  :conditions => ["is_available = ? ", true]
  scope :pds,  :conditions => ["abbrev = ? ", "PD"]
  scope :cores,  :conditions => ["abbrev = ? ", "CORE"]
  scope :itas,  :conditions => ["abbrev = ? ", "ITA"]
  scope :istas,  :conditions => ["abbrev = ? ", "STAT"]
  scope :cms,  :conditions => ["abbrev = ? ", "CM"]
  scope :elts,  :conditions => ["abbrev = ? ", "ELT"]
  scope :unavailable,  :conditions => ["is_available = ? ", false]
  scope :beta,  :conditions => ["is_beta = ? ", true]
  scope :production,  :conditions => ["is_beta = ? ", false]
  scope :use_folders,  :conditions => ["is_folderable = ? ", true]
  scope :blogable,  :conditions => ["is_blogable = ? ", true]


  def providers
    self.app_providers
  end
####    Apps

  def app_name(option = {})
    if option[:provider]
      option[:provider].app_settings(self).alt_name == '' ? self.name : option[:provider].app_settings(self).alt_name
    else
      self.name
    end
  end

  def app_abbrev(option = {})
    if option[:provider]
      option[:provider].app_settings(self).alt_abbrev == '' ? self.name : option[:provider].app_settings(self).alt_abbrev
    else
      self.abbrev
    end
  end

  def self.core
    self.cores.first
  end

  def self.blog
    self.blogs.first
  end

  def self.itl
    self.itls.first
  end

  def self.ctl
    self.itls.first
  end

  def self.classroom
    self.classrooms.first
  end

  def self.ifa
    self.ifas.first
  end

  def self.pd
    self.pds.first
  end

  def self.ita
    self.itas.first
  end

  def self.ista
    self.istas.first
  end
  def self.stat
    self.ista
  end

  def self.cm
    self.cms.first
  end

  def self.elt
    self.elts.first
  end

  #########
  def provider_app_admins(org)
    Authorization.app_administrator(self)
  end

  def provider_observer_levels(org)
    Authorization.ctl_observers
  end

  def provider_observations(org)
    TltSession.final
  end

  def provider_pd_plans(org)
    UserDlePlan.current
  end

  def active_offerings(org)
    Classroom.active
  end

  def closed_offerings(org)
    Classroom.closed.active
  end

  def opened_offerings(org)
    Classroom.opened.active
  end

  def provider_teachers(org)
    Authorization.teachers
  end

  def provider_panelists(org)
    Authorization.panelists
  end

  def pm_cases(org)
    EltCase.final
  end

  def pm_findings(org)
    EltCaseIndicator.final
  end

  def pm_images(org)
    EltCaseEvidence.all
  end

  #########


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

  def app_link
    if self.core?
      controller = 'fsn'
      action = 'index'
      route = 'root'
    end
    if self.ifa?
      controller = 'apps/assessment'
      #   action = 'manage'
      action = 'index'
      route = 'ifa'
    end
    if self.ita? 
      controller = 'apps/teacher_assess'
      action = 'index'
      route = 'ita'
    end     
    if self.blogs?
      controller = 'apps/blogs'
      action = 'index'
      route = 'blogs'
    end
    if self.ctl?
      controller = 'apps/time_learning'
      action = 'index'
      route = 'ctl'
    end
    if self.classroom?
      controller = 'apps/classroom'
      action = 'index'
      route = 'offering'
    end               
    if self.pd?
      controller = 'apps/staff_develop'
      action = 'index'
      route = 'pd'
    end   
    if self.ista?
      controller = 'apps/school_time'
      action = 'index'
      route = 'stat'
    end    
    if self.cm?
      controller = 'apps/client_manager'
      action = 'index'
      route = 'cm'
    end
    if self.elt?
      controller = 'apps/learning_time'
      action = 'index'
      route = 'elt'
    end
    links = [controller, action, route]
  end

  def link_path
    self.app_link[2] + '_path'
  end

  def link_url
    self.app_link[2] + '_url'
  end
  def route_url
    '/' + self.app_link[2]
  end
  def route_action
    self.app_link[0] + '#' + self.app_link[1]
  end
  def self.ifa_app
    self.ifa.first
  end

  def ifa?
    self.abbrev=="IFA"
  end

  def ita?
    self.abbrev=="ITA"
  end
  
  def core?
    self.abbrev=="CORE"
  end

  def ctl?
    self.abbrev=="CTL"
  end

  def classroom?
    self.abbrev=="CLASSROOM"
  end

  def self.offering
    CoopApp.classroom
  end

  def pd?
    self.abbrev=="PD"
  end

  def blogs?
    self.abbrev=="BLOGS"
  end

  def ista?
    self.abbrev=="STAT"
  end

  def cm?
    self.abbrev=="CM"
  end

  def elt?
    self.abbrev=="ELT"
  end

  def org_settings(org)
    self.coop_app_organizations.for_org(org).first rescue nil
  end
    
  def owners
    self.organizations.select{|o| o.appl_owner?(self)}
  end

  def discussion_owner
    self.app_discussion.organization rescue self.owner
  end

  def app_discussion
    self.app_discussions.first rescue nil
  end

  def available?
    self.is_available
  end

  def beta?
    self.is_beta
  end

  def folderable?
    self.is_folderable
  end

  def blogable?
    self.is_blogable
  end
  
  def enableable?
    self.user_enableable && !self.core?
  end
   
  def providers
    provs = self.coop_app_organizations.provider.collect{|ca| ca.organization}.compact.uniq rescue []
    if provs.empty?
      provs<< self.owner
    end
    provs 
  end
  
  def selected_orgs
    self.coop_app_organizations.selected.collect{|co| co.organization}.compact.uniq.sort_by{|org| [org.name]} rescue []
  end

  def allowed_orgs
    self.coop_app_organizations.allowed.collect{|co| co.organization}.compact.uniq.sort_by{|org| [org.name]} rescue []
  end

  def disallowed_orgs
    self.coop_app_organizations.disallowed.collect{|co| co.organization}.compact.uniq.sort_by{|org| [org.name]} rescue []
  end

  def org_disallowed?(org)
    self.disallowed_orgs.include?(org)
  end

  def alt_name(org)
    org.app_settings(self).alt_name
  end

  def reset_org_options(provider)
    provider.provided_app_orgs(self, true).each do |org|
      if self.elt?
        org.elt_reset_org_option
      end
    end
  end
end
