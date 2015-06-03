class ActQuestionActScoreRange < ActiveRecord::Base
  include PublicPersona

  belongs_to :act_score_range
  belongs_to :act_question
  
  has_many :act_score_ranges
  has_many :act_questions
  
  named_scope :for_mastery_level, lambda{|level| {:conditions => ["act_score_range_id = ? ", level.id]}}

end
