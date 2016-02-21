class IfaStudentLevel < ActiveRecord::Base


  include PublicPersona
  

  belongs_to :act_master
  belongs_to :act_question
  belongs_to :user
  belongs_to :act_submission
  
  scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  scope :since, lambda{| begin_date| {:conditions => ["submission_date >= ?", begin_date]}}
  scope :until, lambda{| end_date| {:conditions => ["submission_date <= ?", end_date]}}
  scope :for_range, lambda{|range| {:conditions => ["mastery_level >= ? AND mastery_level <= ? ", range.lower_score, range.upper_score]}}
  scope :for_range_calibrated, lambda{|range| {:conditions => ["calibrated_mastery_level >= ? AND calibrated_mastery_level <= ? ", range.lower_score, range.upper_score]}}


end
