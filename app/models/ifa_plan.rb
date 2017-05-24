class IfaPlan < ActiveRecord::Base
  include PublicPersona

  attr_accessible :accepted_by, :accepted_date, :act_master_id, :act_subject_id, :current_mastery, :goal_date, :goals, :is_accepted, :needs, :user_id

  belongs_to :act_subject
  belongs_to :user
  has_many :ifa_plan_milestones, :dependent => :destroy
  has_many :ifa_plan_remarks, :dependent => :destroy

  validates_presence_of :act_subject_id, :message => 'Subject Area Not Defined'
  validates_presence_of :user_id, :message => 'User Not Defined'

  def accepted?
    self.is_accepted
  end

  def incomplete?
    self.needs.nil? || self.goals.nil?
  end
  def complete?
    !self.needs.nil? && !self.goals.nil?
  end
  def subject_area
    self.act_subject
  end

  def standard
    self.act_master
  end

  def self.for_subject(subject)
    where('act_subject_id = ?', subject.id)
  end

  def strand_milestones(strand)
    self.ifa_plan_milestones.for_strand(strand)
  end

  def milestones
    self.ifa_plan_milestones
  end

  def remarks
    self.ifa_plan_remarks.by_update_date
  end

  def classroom_lus(classroom)
    lus = []
    classroom.topics.active.each do |lu|
      self.ifa_plan_milestones.each do |ms|
        if lu.act_score_ranges.include?(ms.range) && lu.act_standards.include?(ms.strand)
          lus << lu
        end
      end
      lus
    end
  end

  def milestone_for?(range,strand)
    !self.ifa_plan_milestones.open_for_range_strand(range, strand).empty?
  end

  def achieved_for?(range,strand)
    !self.ifa_plan_milestones.achieved_for_range_strand(range, strand).empty?
  end

end
