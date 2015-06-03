class EltCycleActivity < ActiveRecord::Base

  
  belongs_to :elt_cyle
  belongs_to :elt_type

  named_scope :for_activity, lambda{|activity| {:conditions => ["elt_type_id = ? ", activity.id]}}
  named_scope :for_cycle, lambda{|cycle| {:conditions => ["elt_cycle_id = ? ", cycle.id]}}

end
