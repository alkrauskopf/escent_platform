class ActScoreRangeTopic < ActiveRecord::Base


  belongs_to :act_score_range
  belongs_to :topic
  
  has_many :topics
  has_many :act_score_ranges

  scope :for_mastery_level, lambda{|mstr| {:conditions => ["act_score_range_id = ? ", mstr.id]}}
 
end
