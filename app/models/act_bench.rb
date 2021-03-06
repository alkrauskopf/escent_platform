class ActBench < ActiveRecord::Base

  include PublicPersona

  belongs_to :source_level, :class_name => 'ActScoreRange', :foreign_key => "source_level_id"
  belongs_to :source_strand, :class_name => 'ActStandard', :foreign_key => "source_strand_id"
  belongs_to :act_score_range
  belongs_to :act_standard
  belongs_to :act_subject
  belongs_to :user
  belongs_to :organization 
  belongs_to :co_gle
  belongs_to :act_master
  belongs_to :act_bench_type
  
  has_many :act_bench_act_questions, :dependent => :destroy
  has_many :act_questions, :through => :act_bench_act_questions    
  
  validates_presence_of :act_subject_id
  validates_presence_of :act_master_id
  validates_presence_of :act_standard_id
  validates_presence_of :act_score_range_id
  validates_presence_of :act_bench_type_id

  scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  scope :for_strand, lambda{|strand| {:conditions => ["act_standard_id = ? ", strand.id]}}
  scope :for_mastery_level, lambda{|level| {:conditions => ["act_score_range_id = ? ", level.id]}}
  scope :for_type, lambda{|btype| {:conditions => ["act_bench_type_id = ? ", btype.id]}}
  scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}

  def student_viewable?
    self.active? && self.is_s_viewable
  end

  def taggable?
    self.active? && self.is_q_taggable
  end

  def self.student_benchmarks
    where('is_active AND is_s_viewable')
  end

  def self.teacher_benchmarks
    where('is_active AND is_q_taggable')
  end

  def self.for_scorerange_strand(benches, sr, strand)
    benches.where('act_score_range_id = ? AND act_standard_id = ? AND is_active', sr.id, strand.id).order('pos ASC')
  end

  def self.for_strand(strand)
    where('act_standard_id = ? AND is_active', strand.id).order('pos ASC')
  end

  def self.for_level( sr)
    where('act_score_range_id = ? AND is_active', sr.id).order('pos ASC')
  end

  def self.all_for_level_strand( sr, strand)
    where('act_score_range_id = ? AND act_standard_id = ?', sr.id, strand.id).order('pos ASC')
  end

  def self.disabled_for_level_strand( sr, strand)
    where('act_score_range_id = ? AND act_standard_id = ? AND is_active = ?', sr.id, strand.id, false).order('pos ASC')
  end

  def self.enabled_for_level_strand( sr, strand)
    where('act_score_range_id = ? AND act_standard_id = ? AND is_active', sr.id, strand.id).order('pos ASC')
  end

  def self.enabled_level_strand_type( sr, strand, btype)
    enabled_for_level_strand( sr, strand).select{|b| b.act_bench_type == btype}
  end

  def self.for_co_gle(gle)
    where('co_gle_id = ?', gle.id)
  end

  def benchmark?
    self.act_bench_type.abbrev.upcase == 'B'
  end
  def improvement?
    self.act_bench_type.abbrev.upcase == 'S'
  end
  def evidence?
    self.act_bench_type.abbrev.upcase == 'E'
  end
  def exemplar?
    self.act_bench_type.abbrev.upcase == 'X'
  end

  def active?
    self.is_active
  end

  def destroyable?
    !self.active?
  end

  def other_source_standard
    source_standard = self.source_level.nil? ? nil : self.source_level.standard
    source_standard ||= self.source_strand.nil? ? nil : self.source_strand.standard
  end

  def source_standard
    self.source_level.nil? ? self.act_master : self.source_level.standard
  end

  def strand_origin
    self.source_strand ? self.source_strand : self.act_standard
  end

  def source?
    !self.source_level.nil? || !self.source_strand.nil?
  end

  def source_compatible?
    (self.source_level.nil? && self.source_strand.nil?) || (self.source_level && self.source_strand && (self.source_level.standard == self.source_strand.standard))
  end

  def source_incompatible?
    if !self.source_level.nil? || !self.source_strand.nil?
      incompat = self.source_level.nil? || self.source_strand.nil? || self.source_level.standard != self.source_strand.standard
    else
      incompat = false
    end
    incompat
  end
  def source_subject_mismatch?
    incompat = false
    if !self.source_level.nil? || !self.source_strand.nil?
      if !self.source_level.nil? && (self.source_level.act_subject != self.act_subject)
        incompat = true
      end
      if !self.source_strand.nil? && (self.source_strand.act_subject != self.act_subject)
        incompat = true
      end
    end
    incompat
  end

  def self.active
    where('is_active').order('pos ASC')
  end

  def type_name
    self.act_bench_type ? self.act_bench_type.name.titleize : 'No Type'
  end

  def strand
    self.act_standard ? self.act_standard : nil
  end

  def mastery_level
    self.act_score_range ? self.act_score_range : nil
  end

end




