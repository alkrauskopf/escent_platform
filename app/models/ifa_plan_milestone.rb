class IfaPlanMilestone < ActiveRecord::Base
  include PublicPersona

  attr_accessible :act_score_range_id, :act_standard_id, :description, :ifa_plan_id, :is_achieved, :evidence, :achieve_date, :teacher_id

  belongs_to :ifa_plan
  belongs_to :act_standard
  belongs_to :act_score_range
  belongs_to :teacher, :class_name=> 'User', :foreign_key => :teacher_id
  has_one :act_subject, :through => :ifa_plan
  has_one :student, :through => :ifa_plan, :source=>:user
  has_many :evidences, :class_name => IfaPlanMilestoneEvidence

  def name
    name = (self.strand.nil? ? 'No Strand' : self.strand.abbrev) + ' ' + (self.range.nil? ? 'No Levle' : self.range.range)
  end

  def achieved?
    self.is_achieved
  end

  def self.achieved
    where('is_achieved').order('updated_at DESC')
  end

  def evidence_by_date
    self.evidences.by_date
  end

  def self.not_achieved
    where('is_achieved = ?', false).order('updated_at DESC')
  end

  def open_for_range_strand?(range, strand)
    self.act_score_range_id = range.id &&  self.act_standard_id = strand.id && !self.is_achieved
  end

  def self.open_for_range_strand(range, strand)
    where('act_score_range_id = ? && act_standard_id = ? && is_achieved = ?', range.id, strand.id, false)
  end

  def self.achieved_for_range_strand(range, strand)
    where('act_score_range_id = ? && act_standard_id = ? && is_achieved', range.id, strand.id)
  end

  def self.for_range_strand(range, strand)
    where('act_score_range_id = ? && act_standard_id = ?', range.id, strand.id)
  end

  def self.by_last_updated
    order('updated_at DESC')
  end

  def self.for_strand(strand)
    where('act_standard_id = ?', strand.id).includes(:act_score_range).order('is_achieved ASC, act_score_ranges.lower_score ASC')
  #  where('act_standard_id = ?', strand.id).order('is_achieved ASC')
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

  def strand_subject
    self.strand? ? self.strand.act_subject : nil
  end

  def range_subject
    self.range? ? self.range.act_subject : nil
  end

  def range_standard
    self.range? ? self.range.act_master : nil
  end

end
