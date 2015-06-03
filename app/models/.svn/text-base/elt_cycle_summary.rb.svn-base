class EltCycleSummary < ActiveRecord::Base

  include PublicPersona
    
  belongs_to :elt_cycle
  belongs_to :elt_type
  belongs_to :elt_indicator

  named_scope :for_indicator, lambda{|ind| {:conditions => ["elt_indicator_id = ?", ind.id]}}
  named_scope :for_provider, lambda{|org| {:include => :elt_cycle, :conditions => ["elt_cycles.organization_id  = ?", org.id]}}
  named_scope :active, lambda{|org| {:include => :elt_cycle, :conditions => ["elt_cycles.is_active"]}}
  named_scope :all,  :order => 'elt_cycle_id ASC'
end
