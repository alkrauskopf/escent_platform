class Authorization < ActiveRecord::Base
  belongs_to :scope, :polymorphic => true
  belongs_to :user
  belongs_to :authorization_level
  
  named_scope :superuser, :conditions => ["authorization_level_id = ?", 1]
  named_scope :friend, :conditions => ["authorization_level_id = ?", 3]
  named_scope :administrator, :conditions => ["authorization_level_id = ?", 2]
  named_scope :content_manager, :conditions => ["authorization_level_id = ?", 4]
  named_scope :content_administrator, :conditions => ["authorization_level_id = ?", 26]
  named_scope :discussion_moderator, :conditions => ["authorization_level_id = ?", 5]
  named_scope :data_owner, :conditions => ["authorization_level_id = ?", 6]
  named_scope :classroom_manager, :conditions => ["authorization_level_id = ?", 7]
  named_scope :colleague, :conditions => ["authorization_level_id = ?", AuthorizationLevel.colleague]
  named_scope :teacher, :conditions => ["authorization_level_id = ?", 16]  
  named_scope :elt_reviewer, :conditions => ["authorization_level_id = ?", 27]
 # ALK new authorization for reporting and data access (following causes error in /views/site/discussions/_discussion_by_same_author.html.erb)
#  named scope :data_owner, :condition => ["authorization_level_id = ?", 6]

  named_scope :for_level, lambda{|org, level| {:conditions => ["authorization_level_id = ? AND scope_id = ?", level.id, org.id]}}
  
  def self.friend_with_org_name(user, order_by)
    order = (order_by == "headerSortDown" ? "name DESC" : "name")
    conditions = "SELECT authorizations.*, organizations.name AS name FROM authorizations, organizations WHERE authorization_level_id = 3 AND user_id = #{user.id} AND authorizations.scope_id = organizations.id ORDER BY " << order
    Authorization.find_by_sql conditions
    # Authorization.find_by_sql ["SELECT authorizations.*, organizations.name AS name FROM authorizations, organizations WHERE authorization_level_id = ? AND user_id = ? AND authorizations.scope_id = organizations.id ORDER BY name DESC", 3, user.id]
  end
end
