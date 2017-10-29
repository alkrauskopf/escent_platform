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

  def updateable?(user)
    self.user == user
  end

  def notifyable?
    !self.user.guardians.empty?
  end

  def relevant_teachers(org)
    org.classrooms.for_subject(self.act_subject).precision_prep.map{|c| c.teachers_for_student(self.user)}.flatten.compact.uniq
  end

  def remarkable?(user)
    user.teacher?
  end

  def achieveable?(user)
    remarkable?(user) || updateable?(user)
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

  def ranges(standard)
    self.act_subject ? standard.mastery_levels(self.act_subject) : []
  end

  def strands(standard)
    self.act_subject ? standard.strands(self.act_subject) : []
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

  def evidence_list
    self.milestones.map{|m| m.evidences}.flatten
  end

  def remarks
    self.ifa_plan_remarks.by_update_date
  end

  def classroom_lus(classroom)
    lus = []
    classroom.topics.active.each do |lu|
      self.ifa_plan_milestones.not_achieved.each do |ms|
        if lu.act_standards.include?(ms.strand)
          lus << lu
        end
      end
    end
    lus.uniq
  end

  def milestone_for?(range,strand)
    !self.ifa_plan_milestones.open_for_range_strand(range, strand).empty?
  end

  def achieved_for?(range,strand)
    !self.ifa_plan_milestones.achieved_for_range_strand(range, strand).empty?
  end

  def milestone_strands
    self.ifa_plan_milestones.map{|m| m.strand}.compact.uniq.sort_by{|s| s.pos}
  end

  def open_milestone_strands
    self.ifa_plan_milestones.not_achieved.map{|m| m.strand}.compact.uniq.sort_by{|s| s.pos}
  end

  def open_milestone_strands_abbrev
    self.open_milestone_strands.map{|s| s.abbrev.upcase}.join(', ')
  end

  def open_milestone_ranges
    self.ifa_plan_milestones.not_achieved.map{|m| m.range}.compact.uniq
  end

  def open_milestone_range_endpoints
    self.open_milestone_ranges.map{|r| r.lower_score}.min.to_s + ' - ' + self.open_milestone_ranges.map{|r| r.upper_score}.max.to_s
  end


end
