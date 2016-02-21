class Discussion < ActiveRecord::Base
  include PublicPersona
  
  acts_as_tree
  
  belongs_to :discussionable, :polymorphic => true
  belongs_to :user
  belongs_to :organization
  
  has_many  :reported_abuses, :class_name => "ReportedAbuse", :as => :entity, :dependent => :destroy
  
  scope :suspended, :conditions => ["is_suspended = ?", true]
  
  scope :active, :conditions => ["!is_suspended"]
  
  scope :parent_id_blank, :conditions => ["parent_id IS NULL"]
  
  cattr_reader :per_page
  @@per_page = 10
  
  def update_last_posted_at(timestamp)
    self.update_attributes :last_posted_at => timestamp
    self.root.update_last_posted_at(timestamp) if self.parent
  end
  
  def report_abuse(options)
    self.reported_abuses.create(:abuse => options[:abuse], :organization => self.organization, :user => options[:user])
  end
  
  def suspend!(options={})
    self.update_attributes :suspended_at => Time.now, :suspended_by => options[:user], :is_suspended => true
    self.children.each{|child| child.suspend!(options)}
  end  
  
  def unsuspend!(options={})
    self.update_attributes :suspended_at => nil, :suspended_by => options[:user], :is_suspended => false
    self.children.each{|child| child.unsuspend!(options)}
  end  
  
  def is_deleted?
    self.is_delete
  end
  
  def make_as_delete(user)
    if User.find_by_id(user)
      self.update_attribute(:delete_user, user)
      self.update_attribute(:is_delete, true)
    end
  end
end
