class Role < ActiveRecord::Base
  belongs_to :scope, :polymorphic => true
  belongs_to :user
  has_many :role_memberships
  has_many :users, :through => :role_memberships
  has_many :authorization_levels
  
  scope :associates, :conditions => {:name => "Associates"}
  scope :administrator, :conditions => {:name => 'Administrator'}
  scope :member, :conditions => {:name => 'Member'}

  before_save :before_save_method
  def before_save_method
    self.user_id = 0 unless self.user_id
  end

  # BuiltinOrganizationRoles = ["Associates", "Member", "Moderator", "Administrator"]

  def builtin?
    self.user_id == 1
  end
  
  def can_be_deleted?
#  !self.builtin? && self.role_memberships.empty?
    self.role_memberships.empty?
  end
end
