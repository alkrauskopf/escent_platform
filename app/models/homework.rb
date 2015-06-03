class Homework < ActiveRecord::Base

  belongs_to :user
  belongs_to :classroom
  belongs_to :content_object_type

  has_attached_file :homework, :path => ":rails_root/public/homeworklibrary/:id/:basename.:extension", :url => "/homeworklibrary/:id/:basename.:extension"

  validates_presence_of :title, :message => "(You Must Have A Title)"
  validates_presence_of :teacher_id, :message => "(You Must Identify Teacher)"
  validates_presence_of :content_object_type_id, :message => "(The File Type Is Not Allowed)"

  named_scope :active,  :conditions => ["is_deleted IS NULL OR is_deleted IS FALSE"]
  named_scope :processed,  :conditions => ["is_deleted = ? ", true]
  named_scope :for_teacher, lambda{|teacher| {:conditions => ["teacher_id = ?", teacher.id], :order => 'created_at ASC'}}
end
