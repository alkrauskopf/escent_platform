class ClassroomReferral < ActiveRecord::Base

  belongs_to :classroom, :foreign_key => "classroom_id"
  belongs_to :topic,  :foreign_key => "topic_id"
  
  acts_as_list :scope => :classroom

  has_many :topics
  has_many :classrooms
  
  scope :for_topic, lambda{| topic| {:conditions => ["topic_id = ?", topic.id]}}
  scope :for_offering, lambda{| offering| {:conditions => ["classroom_id = ?", offering.id]}}

end
