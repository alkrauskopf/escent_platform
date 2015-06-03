class IfaQuestionPerformance < ActiveRecord::Base

  belongs_to :act_question
  belongs_to :act_score_range

  named_scope :for_range, lambda{|range| {:conditions => ["act_score_range_id = ? ", range.id]}}


end
