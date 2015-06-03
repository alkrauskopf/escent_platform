class ActStandardTopic < ActiveRecord::Base

  belongs_to :act_standard
  belongs_to :topic
  
  has_many :topics
  has_many :act_standards
  
  acts_as_list :scope => :topic
 
  named_scope :for_strand, lambda{|strand| {:conditions => ["act_standard_id = ? ", strand.id]}}

end
