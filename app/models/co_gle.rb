class CoGle < ActiveRecord::Base

  include PublicPersona
  
  has_many :act_benches, :dependent => :destroy

  belongs_to :act_standard
  belongs_to :co_grade_level
  
  
  scope :for_strand, lambda{|strand| {:conditions => ["act_standard_id = ? ", strand.id]}}


  def self.for_grade_level(level)
    where('co_grade_level_id = ?', level.id)
  end

end
