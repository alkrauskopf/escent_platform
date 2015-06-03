class Channel < ActiveRecord::Base
  include PublicPersona
  
  acts_as_tree
  
  belongs_to :organization
  belongs_to :user
  has_many :channel_contents
  has_many :contents, :through => :channel_contents, :order => "position"
  has_many :setting_values, :as => :scope, :dependent => :destroy
  
  accepts_nested_attributes_for :setting_values
  
  named_scope :active,  :conditions => ["publish_start_date <= ? AND (publish_end_date IS NULL OR publish_end_date > ?)", Time.now, Time.now], :order => "title"
  named_scope :pending, :conditions => ["(publish_start_date > ? OR publish_start_date IS NULL)", Time.now], :order => "title"
  named_scope :closed,  :conditions => ["publish_end_date <= ?", Time.now], :order => "title"
  named_scope :searchable, :conditions => {:searchable => true}
  validates_presence_of :title

end
