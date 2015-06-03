class ActAssessmentScoreRange < ActiveRecord::Base


  belongs_to :act_assessment
  belongs_to :act_master

  named_scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}

end
