class ActStandardContent < ActiveRecord::Base

  belongs_to :content
  belongs_to :act_standard
  
  has_many :act_standards
  has_many :contents
  
  acts_as_list :scope => :content
  
  named_scope :for_strand, lambda{|strand| {:conditions => ["act_standard_id = ? ", strand.id]}}

end
