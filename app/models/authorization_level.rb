class AuthorizationLevel < ActiveRecord::Base

  belongs_to :coop_app

  has_many :authorizations
#  has_many :authorizable_actions
#  has_many :roles
  has_many :users, :through => :authorizations 
  has_many :applicable_scopes

  scope :favorite, :conditions => ["name = ?", "favorite"]
  scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id]}}


  def self.auth_levels_for(role)
    self.where('name = ?', role )
  end

  def self.for_app(app)
    self.where('coop_app_id = ?', app.id )
  end

  def self.organizations
    ApplicableScope.for_organizations.collect{|as| as.authorization_level}.compact
  end

  def self.organizations_for_app(app)
    self.organizations.select{|a| a.coop_app_id == app.id}
  end

  def self.classrooms
    ApplicableScope.for_classrooms.collect{|as| as.authorization_level}.compact
  end

  def self.users
    ApplicableScope.for_users.collect{|as| as.authorization_level}.compact
  end

  def self.apps
    ApplicableScope.for_apps.collect{|as| as.authorization_level}.compact
  end

  def self.content
    ApplicableScope.for_content.collect{|as| as.authorization_level}.compact
  end


  ###   New Authorization Level Methods

  def self.app_superuser(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'superuser', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_superusers
    self.where('name = ?', 'superuser' )
  end
###

  def self.superuser
    self.app_superuser(CoopApp.core)
  end

###
  def self.app_administrator(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'administrator', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_administrators
    self.where('name = ?', 'administrator' )
  end

  def self.app_beta_user(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'beta_user', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_beta_users
    self.where('name = ?', 'beta_user' )
  end

  def self.app_colleague(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'colleague', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_colleagues
    self.where('name = ?', 'colleague' )
  end

  def self.app_consultant(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'consultant', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_consultants
    self.where('name = ?', 'consultant' )
  end

  def self.app_favorite(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'favorite', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_favorites
    self.where('name = ?', 'favorite' )
  end

  def self.app_friend(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'friend', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_friends
    self.where('name = ?', 'friend' )
  end

  def self.app_knowledge_manager(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'knowledge_manager', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_knowledge_managers
    self.where('name = ?', 'knowledge_manager' )
  end

  def self.app_library_administrator(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'library_administrator', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_library_administrators
    self.where('name = ?', 'library_administrator' )
  end

  def self.app_observer(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'observer', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_observers
    self.where('name = ?', 'observer' )
  end

  def self.app_panelist(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'panelist', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_panelists
    self.where('name = ?', 'panelist' )
  end

  def self.app_reviewer(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'reviewer', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_reviewers
    self.where('name = ?', 'reviewer' )
  end

  def self.app_student(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'student', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_students
    self.where('name = ?', 'student' )
  end

  def self.app_teacher(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'teacher', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_teachers
    self.where('name = ?', 'teacher' )
  end

  def self.app_user(app)
    if app.nil?
      levels = []
    else
      levels = self.where('name = ? AND coop_app_id = ?', 'user', app.id )
    end
    levels.empty? ? nil : levels.first
  end
  def self.app_users
    self.where('name = ?', 'user' )
  end

#######

  def superuser?
    self.name == 'superuser'
  end
  
  def administrator?
    self.name == 'administrator'
  end

  def self.administrator
    self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.core.id ).first
  end
  
  def self.friend
    self.where('name = ? AND coop_app_id = ?', 'friend', CoopApp.core.id ).first
  end
 
  def friend?
    self.name == 'friend'
  end

  def self.content_manager
    self.where('name = ? AND coop_app_id = ?', 'knowledge_manager', CoopApp.core.id ).first
  end

  ## temp
  def content_manager?
    (self.name == 'knowledge_manager') && (self.coop_app_id == CoopApp.core.id)
  end

  def self.content_administrator
    self.where('name = ? AND coop_app_id = ?', 'library_administrator', CoopApp.core.id ).first
  end
  
  def content_administrator?
    (self.name == 'library_administrator') && (self.coop_app_id == CoopApp.core.id)
  end

  def self.knowledge_manager
    self.where('name = ? AND coop_app_id = ?', 'knowledge_manager', CoopApp.core.id ).first
  end

  def knowledge_manager?
    self.name == 'knowledge_manager'
  end

  def self.library_administrator
    self.where('name = ? AND coop_app_id = ?', 'library_administrator', CoopApp.core.id ).first
  end

  def library_administrator?
    self.name == 'knowledge_manager'
  end

  def self.classroom_manager
    self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.classroom.id ).first
  end
  
  def classroom_manager?
    (self.name == 'administrator') && (self.coop_app_id == CoopApp.classroom.id)
  end
  
  def self.leader
    self.where('name = ? AND coop_app_id = ?', 'teacher', CoopApp.classroom.id ).first
  end

  def leader?
    (self.name == 'teacher') && (self.coop_app_id == CoopApp.classroom.id)
  end
  
  def self.participant
    self.where('name = ? AND coop_app_id = ?', 'student', CoopApp.classroom.id ).first
  end
  
  def participant?
    (self.name == 'student') && (self.coop_app_id == CoopApp.classroom.id)
  end
  
  def self.favorite
    self.where('name = ? AND coop_app_id = ?', 'favorite', CoopApp.core.id ).first
  end
  
  def favorite?
    self.name == 'favorite'
  end
  
  def self.colleague
    self.where('name = ? AND coop_app_id = ?', 'colleague', CoopApp.core.id ).first
  end
  
  def colleague?
    self.name == 'colleague'
  end

  def self.beta_user
    self.where('name = ? AND coop_app_id = ?', 'beta_user', CoopApp.core.id ).first
  end

  def beta_user?
    self.name == 'beta_user'
  end

  def self.ifa_admin
    self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.ifa.id ).first
  end
  
  def ifa_admin?
    (self.name == 'administrator') && (self.coop_app_id == CoopApp.ifa.id)
  end

  def self.blogger
    self.where('name = ? AND coop_app_id = ?', 'panelist', CoopApp.blog.id ).first
  end
 
  def self.blogger?
    (self.name == 'panelist') && (self.coop_app_id == CoopApp.blog.id)
  end

  def self.blog_admin
    self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.blog.id ).first
  end
 
  def self.blog_admin?
    (self.name == 'administrator') && (self.coop_app_id == CoopApp.blog.id)
  end

  def self.itl_observer
    self.where('name = ? AND coop_app_id = ?', 'observer', CoopApp.ctl.id ).first
  end
  def self.ctl_observer
    self.where('name = ? AND coop_app_id = ?', 'observer', CoopApp.ctl.id ).first
  end

  def self.itl_observer?
     (self.name == 'observer') && (self.coop_app_id == CoopApp.ctl.id)
  end
  def self.ctl_observer?
    (self.name == 'observer') && (self.coop_app_id == CoopApp.ctl.id)
  end

  def self.itl_admin
   self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.ctl.id ).first
  end
  def self.ctl_admin
    self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.ctl.id ).first
  end

  def self.itl_admin?
     (self.name == 'administrator') && (self.coop_app_id == CoopApp.ctl.id)
  end
  def self.ctl_admin?
    (self.name == 'administrator') && (self.coop_app_id == CoopApp.ctl.id)
  end

  def self.teacher
    self.where('name = ? AND coop_app_id = ?', 'teacher', CoopApp.core.id ).first
  end
 
  def self.teacher?
    (self.name == 'teacher') && (self.coop_app_id == CoopApp.core.id)
  end

  def self.pd_admin
    self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.pd.id ).first
  end
 
   def self.pd_admin?
     (self.name == 'administrator') && (self.coop_app_id == CoopApp.pd.id)
  end

  ####  Temp

  def self.cm_admin
    self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.cm.id ).first
  end
 
  def self.cm_admin?
    (self.name == 'administrator') && (self.coop_app_id == CoopApp.cm.id)
  end 

  def self.cm_km
    self.where('name = ? AND coop_app_id = ?', 'knowledge_manager', CoopApp.cm.id ).first
  end
 
  def self.cm_km?
    (self.name == 'knowledge_manager') && (self.coop_app_id == CoopApp.cm.id)
  end 

  def self.consultant
    self.where('name = ? AND coop_app_id = ?', 'consultant', CoopApp.cm.id ).first
  end
 
  def self.consultant?
    (self.name == 'consultant') && (self.coop_app_id == CoopApp.cm.id)
  end       

  def self.elt_admin
    self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.elt.id ).first
  end
 
  def self.elt_admin?
    (self.name == 'administrator') && (self.coop_app_id == CoopApp.elt.id)
  end 

  def self.elt_team
    self.where('name = ? AND coop_app_id = ?', 'user', CoopApp.elt.id ).first
  end

  def self.elt_team?
    (self.name == 'user') && (self.coop_app_id == CoopApp.elt.id)
  end

  def self.elt_user
    self.where('name = ? AND coop_app_id = ?', 'user', CoopApp.elt.id ).first
  end

  def self.elt_user?
    (self.name == 'user') && (self.coop_app_id == CoopApp.elt.id)
  end

  def self.elt_reviewer
    self.where('name = ? AND coop_app_id = ?', 'reviewer', CoopApp.elt.id ).first
  end
  
  def elt_reviewer?
    (self.name == 'reviewer') && (self.coop_app_id == CoopApp.elt.id)
  end

  def self.stat_admin
    self.where('name = ? AND coop_app_id = ?', 'administrator', CoopApp.ista.id ).first
  end

  def self.stat_admin?
    (self.name == 'administrator') && (self.coop_app_id == CoopApp.ista.id)
  end

  def self.stat_user
    self.where('name = ? AND coop_app_id = ?', 'user', CoopApp.ista.id ).first
  end

  def self.stat_user?
    (self.name == 'user') && (self.coop_app_id == CoopApp.ista.id)
  end

  def x_all_authorizable_actions
    (self.authorizable_actions + self.children.collect{|authorization_level| authorization_level.all_authorizable_actions}).flatten
  end
  
  def x_authorized_for_action?(action)
    self.superuser? || self.all_authorizable_actions.include?(action)
  end

  def self.app_authorizations(org)
    ApplicableScope.for_scope(org).collect{|a| a.authorization_level}.select{|al| !al.superuser?}
  end

  def self.app_provider_authorizations
    self.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'friend') AND applicable_scopes.name = ?", "Organization"]).sort_by{|a| [a.coop_app_id, a.name]}
  end
end
