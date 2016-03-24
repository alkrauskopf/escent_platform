class EltCycleSummary < ActiveRecord::Base

  include PublicPersona
    
  belongs_to :elt_cycle
  belongs_to :elt_type
  belongs_to :elt_indicator

  scope :for_indicator, lambda{|ind| {:conditions => ["elt_indicator_id = ?", ind.id]}}
  scope :for_provider, lambda{|org| {:include => :elt_cycle, :conditions => ["elt_cycles.organization_id  = ?", org.id]}}
  scope :active, {:include => :elt_cycle, :conditions => ["elt_cycles.is_active"]}
  scope :all,  :order => 'elt_cycle_id ASC'

end
