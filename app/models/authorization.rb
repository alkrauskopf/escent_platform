class Authorization < ActiveRecord::Base
  belongs_to :scope, :polymorphic => true
  belongs_to :user
  belongs_to :authorization_level
  
#  scope :superuser, :conditions => ["authorization_level_id = ?", 1]
#  scope :friend, :conditions => ["authorization_level_id = ?", 3]
#  scope :administrator, :conditions => ["authorization_level_id = ?", 2]
#  scope :content_manager, :conditions => ["authorization_level_id = ?", 4]
#  scope :content_administrator, :conditions => ["authorization_level_id = ?", 26]
#  scope :discussion_moderator, :conditions => ["authorization_level_id = ?", 5]
#  scope :data_owner, :conditions => ["authorization_level_id = ?", 6]
#  scope :classroom_manager, :conditions => ["authorization_level_id = ?", 7]
#  scope :colleague, :conditions => ["authorization_level_id = ?", AuthorizationLevel.colleague]
#  scope :teacher, :conditions => ["authorization_level_id = ?", 16]
#  scope :elt_reviewer, :conditions => ["authorization_level_id = ?", 27]

  # ALK new authorization for reporting and data access (following causes error in /views/site/discussions/_discussion_by_same_author.erb)
#  named scope :data_owner, :condition => ["authorization_level_id = ?", 6]

#  scope :for_level, lambda{|org, level| {:conditions => ["authorization_level_id = ? AND scope_id = ?", level.id, org.id]}}

  def self.friend_with_org_name(user, order_by)
    order = (order_by == "headerSortDown" ? "name DESC" : "name")
    conditions = "SELECT authorizations.*, organizations.name AS name FROM authorizations, organizations WHERE authorization_level_id = 3 AND user_id = #{user.id} AND authorizations.scope_id = organizations.id ORDER BY " << order
    Authorization.find_by_sql conditions
    # Authorization.find_by_sql ["SELECT authorizations.*, organizations.name AS name FROM authorizations, organizations WHERE authorization_level_id = ? AND user_id = ? AND authorizations.scope_id = organizations.id ORDER BY name DESC", 3, user.id]
  end

  def self.for_entity(entity)
    self.where('scope_type = ? AND scope_id = ?', entity.class.to_s, entity.id )
  end

  def self.for_scope(scope)
    self.where('scope_type = ?', scope.class.to_s )
  end

  def self.for_level(level)
    self.where('authorization_level_id = ?', level.id )
  end

  def self.superuser
    level = AuthorizationLevel.app_superuser(CoopApp.core)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end

  def self.friend
    level = AuthorizationLevel.app_friend(CoopApp.core)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end

  def self.administrator
    level = AuthorizationLevel.app_administrator(CoopApp.core)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end

  def self.content_manager
    level = AuthorizationLevel.app_knowledge_manager(CoopApp.core)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end

  def self.knowledge_manager
    level = AuthorizationLevel.app_knowledge_manager(CoopApp.core)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end

  def self.content_administrator
    level = AuthorizationLevel.app_library_administrator(CoopApp.core)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end

  def self.classroom_manager
    level = AuthorizationLevel.app_administrator(CoopApp.classroom)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end

  def self.colleague
    level = AuthorizationLevel.app_colleague(CoopApp.core)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end

  def self.teacher
    level = AuthorizationLevel.app_teacher(CoopApp.core)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end

  def self.elt_reviewer
    level = AuthorizationLevel.app_reviewer(CoopApp.elt)
    level.nil? ? [] : self.select{|a| a.authorization_level_id == level.id}
  end
end
