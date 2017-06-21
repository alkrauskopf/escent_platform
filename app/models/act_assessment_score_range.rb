class ActAssessmentScoreRange < ActiveRecord::Base


  belongs_to :act_assessment
  belongs_to :act_master

  has_many :upper_bound_assessments, :source => 'ActAssessment', :foreign_key => 'upper_level_id'
  has_many :lower_bound_assessments, :source => 'ActAssessment', :foreign_key => 'lower_level_id'

  scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}

end
