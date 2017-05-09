class IfaPlanMilestone < ActiveRecord::Base
  include PublicPersona

  attr_accessible :act_score_range_id, :act_standard_id, :description, :ifa_plan_id, :is_achieved, :evidence

  belongs_to :ifa_plan
  belongs_to :act_standard
  belongs_to :act_score_range


  def achieved?
    self.is_achieved
  end

  def self.achieved
    where('is_achieved').order('updated_at DESC')
  end

  def self.open
    where('is_achieved = ?', false).order('updated_at DESC')
  end

  def self.by_last_updated
    order('updated_at DESC')
  end

  def self.for_strand(strand)
    where('act_standard_id = ?', strand.id).order('updated_at DESC')
  end

  def range
    self.act_score_range
  end

  def range?
    !self.range.nil?
  end

  def plan
    self.ifa_plan
  end

  def strand
    self.act_standard
  end

  def strand?
    !self.strand.nil?
  end

  def standard
    self.strand? ? self.strand.act_master : nil
  end

  def standard?
    !self.standard.nil?
  end

end
