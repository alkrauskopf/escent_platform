class EltCycleActivity < ActiveRecord::Base

  
  belongs_to :elt_cycle
  belongs_to :elt_type

  scope :for_activity, lambda{|activity| {:conditions => ["elt_type_id = ? ", activity.id]}}
  scope :for_cycle, lambda{|cycle| {:conditions => ["elt_cycle_id = ? ", cycle.id]}}

end
