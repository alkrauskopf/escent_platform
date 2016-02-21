class CoGle < ActiveRecord::Base

  include PublicPersona
  
  has_many :act_benches, :dependent => :destroy

  belongs_to :act_standard
  belongs_to :co_grade_level
  
  
  scope :for_strand, lambda{|strand| {:conditions => ["act_standard_id = ? ", strand.id]}}
  
end
