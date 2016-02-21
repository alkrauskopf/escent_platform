class TopicContent < ActiveRecord::Base
  belongs_to :content
  belongs_to :topic
  belongs_to :folder
  
  has_many :topics
  has_many :contents
  has_many :folders
  
  acts_as_list :scope => :topic
  
  scope :unfoldered, :conditions => [ "folder_id IS NULL"]
  scope :foldered, :conditions => [ "folder_id IS NOT NULL" ], :order => "position"
  scope :for_lu, lambda{|lu| {:conditions => ["topic_id = ? ", lu.id], :order => "position" }}
  scope :for_folder, lambda{|folder| {:conditions => ["folder_id = ? ", folder.id], :order => "position" }}
  scope :for_resource, lambda{|rsrc| {:conditions => ["content_id = ? ", rsrc.id], :order => "position" }}
  
end
