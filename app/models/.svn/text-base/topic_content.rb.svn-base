class TopicContent < ActiveRecord::Base
  belongs_to :content
  belongs_to :topic
  belongs_to :folder
  
  has_many :topics
  has_many :contents
  has_many :folders
  
  acts_as_list :scope => :topic
  
  named_scope :unfoldered, :conditions => [ "folder_id IS NULL"]
  named_scope :foldered, :conditions => [ "folder_id IS NOT NULL" ], :order => "position"   
  named_scope :for_lu, lambda{|lu| {:conditions => ["topic_id = ? ", lu.id], :order => "position" }}
  named_scope :for_folder, lambda{|folder| {:conditions => ["folder_id = ? ", folder.id], :order => "position" }}
  named_scope :for_resource, lambda{|rsrc| {:conditions => ["content_id = ? ", rsrc.id], :order => "position" }}
  
end
