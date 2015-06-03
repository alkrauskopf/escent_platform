class DleCycleOrg < ActiveRecord::Base

  belongs_to :tlt_survey_type
  belongs_to :dle_cycle
  belongs_to :organization

  named_scope :for_dle_cycle,  lambda{|cycle | {:conditions => ["dle_cycle_id = ?", cycle.id]}}


end
