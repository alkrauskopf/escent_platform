class Role < ActiveRecord::Base
  belongs_to :scope, :polymorphic => true
  belongs_to :user
  has_many :role_memberships
  has_many :users, :through => :role_memberships
  has_many :authorization_levels
  
  named_scope :associates, :conditions => {:name => "Associates"}
  named_scope :administrator, :conditions => {:name => 'Administrator'}
  named_scope :member, :conditions => {:name => 'Member'}
  
  # BuiltinOrganizationRoles = ["Associates", "Member", "Moderator", "Administrator"]
  
  def builtin?
    self.user_id == 1
  end
  
  def before_save
    self.user_id = 0 unless self.user_id
  end
  
  def can_be_deleted?
#  !self.builtin? && self.role_memberships.empty?
    self.role_memberships.empty?
  end
end
