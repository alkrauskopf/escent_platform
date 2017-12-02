class IfaDashboardCell < ActiveRecord::Base
  include PublicPersona

  before_save :cell_id

  belongs_to :ifa_dashboard
  belongs_to :act_master
  belongs_to :act_score_range
  belongs_to :act_standard
 
  scope :for_standard_range_and_strand, lambda{|standard, range, strand| {:conditions => ["act_master_id = ? && act_score_range_id = ? && act_standard_id = ?", standard.id, range.id, strand.id]}}
  scope :for_range_and_strand, lambda{|range, strand| {:conditions => ["act_score_range_id = ? && act_standard_id = ?", range.id, strand.id]}}
  scope :with_range_id, lambda{|range_id| {:conditions => ["act_score_range_id = ? ", range_id]}}
  scope :with_strand_id, lambda{|strand_id| {:conditions => ["act_standard_id = ? ", strand_id]}}
  scope :for_standard, lambda{|standard | {:conditions => ["act_master_id = ? ", standard.id]}}

  def self.levels_for_standard(standard)
    where('act_master_id = ?', standard.id).map{|c| c.act_score_range}.uniq.sort_by{|r| r.lower_score}
  end

  def self.for_standard(standard)
    where('act_master_id = ?', standard.id)
  end

  def self.for_level(level)
    where('act_score_range_id = ?', level.id)
  end

  private

  def cell_id
    self.cell = self.act_score_range_id.to_s + '|' + self.act_standard_id.to_s
  end

end
