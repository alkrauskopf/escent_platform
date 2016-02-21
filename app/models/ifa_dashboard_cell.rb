class IfaDashboardCell < ActiveRecord::Base
  include PublicPersona

  belongs_to :ifa_dashboard
  belongs_to :act_master
  belongs_to :act_score_range
  belongs_to :act_standard
 
  scope :for_standard_range_and_strand, lambda{|standard, range, strand| {:conditions => ["act_master_id = ? && act_score_range_id = ? && act_standard_id = ?", standard.id, range.id, strand.id]}}
  scope :for_range_and_strand, lambda{|range, strand| {:conditions => ["act_score_range_id = ? && act_standard_id = ?", range.id, strand.id]}}
  scope :with_range_id, lambda{|range_id| {:conditions => ["act_score_range_id = ? ", range_id]}}
  scope :with_strand_id, lambda{|strand_id| {:conditions => ["act_standard_id = ? ", strand_id]}}
  scope :for_standard, lambda{|standard | {:conditions => ["act_master_id = ? ", standard.id]}}
  
  
end
