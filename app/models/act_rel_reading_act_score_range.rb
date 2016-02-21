class ActRelReadingActScoreRange < ActiveRecord::Base

  include PublicPersona

  belongs_to :act_score_range
  belongs_to :act_rel_reading
  belongs_to :act_master
  
  has_many :act_score_ranges
  has_many :act_rel_readings
 
  scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  scope :for_mastery_level, lambda{|mstr| {:conditions => ["act_score_range_id = ? ", mstr.id]}}

end
