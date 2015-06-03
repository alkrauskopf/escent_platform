class AuthorizationLevel < ActiveRecord::Base
  acts_as_tree 
  
  belongs_to :coop_app

  has_many :authorizations
  has_many :authorizable_actions
  has_many :roles
  has_many :users, :through => :authorizations 
  has_many :applicable_scopes

  named_scope :favorite, :conditions => ["name = ?", "favorite"]
  
  
  def self.superuser
    @superuser ||= self.find 1
  end
  
  def superuser?
    self.id == 1
  end
  
  def administrator?
    self.id == 2
  end

  def self.administrator
    @adm ||= self.find 2
  end
  
  def self.friend
    @friend ||= self.find 3
  end
 
  def friend?
    self.id == 3
  end 
    
  def self.content_manager
    @content_manager ||= self.find 4
  end
  
  def content_manager?
    self.id == 4
  end
    
  def self.content_administrator
    @content_administrator ||= self.find 26
  end
  
  def content_administrator?
    self.id == 26
  end
  
  def self.classroom_manager
    @classroom_manager ||= self.find 5
  end
  
  def classroom_manager?
    self.id == 5
  end
  
  def self.leader
    @leader ||= self.find 6
  end
  
  def leader?
    self.id == 6
  end
  
  def self.participant
    @participant ||= self.find 7
  end
  
  def participant?
    self.id == 7
  end
  
  def self.favorite
    @favorite ||= self.find 8
  end
  
  def favorite?
    self.id == 8
  end
  
  def self.colleague
    @colleague ||= self.find 9
  end
  
  def colleague?
    self.id == 9
  end

  def beta_user?
    self.id == 10
  end

  def self.ifa_admin
    @ifa_admin ||= self.find 11
  end
  
  def ifa_admin?
    self.id == 11
  end

  def self.blogger
    @blogger ||= self.find 13
  end
 
  def self.blogger?
    self.id == 13
  end

  def self.blog_admin
    @blog_admin ||= self.find 28
  end
 
  def self.blog_admin?
    self.id == 28
  end

  def self.itl_observer
    @ilt_tracker ||= self.find 14
  end
 
   def self.itl_observer?
    self.id == 14
  end

  def self.itl_admin
    @ilt_admin ||= self.find 15
  end
 
   def self.itl_admin?
    self.id == 15
  end 

  def self.teacher
    @teacher ||= self.find 16
  end
 
  def self.teacher?
    self.id == 16
  end

  def self.pd_admin
    @pd_admin ||= self.find 17
  end
 
   def self.pd_admin?
    self.id == 17
  end
 
  def self.app_superuser
    @app_superuser ||= self.find 18
  end

  def self.app_superuser
    self.id == 18
  end

  def self.cm_admin
    @cm_admin ||= self.find 21
  end
 
  def self.cm_admin?
    self.id == 21
  end 

  def self.km
    @cm_km ||= self.find 22
  end
 
  def self.km?
    self.id == 22
  end 

  def self.consultant
    @consultant ||= self.find 23
  end
 
  def self.consultant?
    self.id == 23
  end       

  def self.elt_admin
    @elt_admin ||= self.find 24
  end
 
  def self.elt_admin?
    self.id == 24
  end 

  def self.elt_team
    @elt_team ||= self.find 25
  end
 
  def self.elt_team?
    self.id == 25
  end
  
  def self.elt_reviewer
    @elt_reviewer ||= self.find 27
  end
  
  def elt_reviewer?
    self.id == 27
  end

  def all_authorizable_actions
    (self.authorizable_actions + self.children.collect{|authorization_level| authorization_level.all_authorizable_actions}).flatten
  end
  
  def authorized_for_action?(action)
    self.superuser? || self.all_authorizable_actions.include?(action)
  end
 
  def user_authorities(usr_id)
    AuthorizationLevel.find(:all, :include => [:authorizations], :conditions => ["authorizations.user_id = ?", usr_id]).uniq
  end 
 
end
