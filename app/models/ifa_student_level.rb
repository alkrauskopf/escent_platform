class IfaStudentLevel < ActiveRecord::Base


  include PublicPersona
  

  belongs_to :act_master
  belongs_to :act_question
  belongs_to :user
  belongs_to :act_submission
  
  named_scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  named_scope :since, lambda{| begin_date| {:conditions => ["submission_date >= ?", begin_date]}} 
  named_scope :until, lambda{| end_date| {:conditions => ["submission_date <= ?", end_date]}} 
  named_scope :for_range, lambda{|range| {:conditions => ["mastery_level >= ? AND mastery_level <= ? ", range.lower_score, range.upper_score]}}
  named_scope :for_range_calibrated, lambda{|range| {:conditions => ["calibrated_mastery_level >= ? AND calibrated_mastery_level <= ? ", range.lower_score, range.upper_score]}}


end
