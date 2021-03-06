class ActStandard < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :act_master
  belongs_to :act_subject
  
  has_many :act_benches, :dependent => :destroy

  has_many :act_standard_topics, :dependent => :destroy
  has_many :topics, :through => :act_standard_topics, :order => "position"  

  has_many :act_standard_contents, :dependent => :destroy  
  has_many :contents, :through => :act_standard_contents, :order => "position"

  has_many :act_question_act_standards, :dependent => :destroy  
  has_many :act_questions, :through => :act_question_act_standards

  has_many :act_assessment_act_standards, :dependent => :destroy
  has_many :act_assessments, :through => :act_assessment_act_standards

  has_many :ifa_plan_milestones
 
  scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
#  scope :for_standard_and_subject, lambda{|standard, subject| {:conditions => ["act_subject_id = ? && act_master_id = ? ", subject.id, standard.id], :order => "abbrev"}}
  scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ?", subject.id]}}


  def self.active_strands(options={})
    if options[:subject].nil? && options[:standard].nil?
      where('is_active').includes(:act_subject, :act_master).order('act_subjects.name DESC, act_masters.abbrev ASC, pos')
    elsif options[:subject].nil? && !options[:standard].nil?
      where('act_master_id = ? AND is_active', options[:standard].id).includes(:act_subject).order('act_subjects.name ASC, pos')
    elsif !options[:subject].nil? && options[:standard].nil?
      where('act_subject_id = ? AND is_active', options[:subject].id).includes(:act_master).order('act_masters.abbrev ASC, pos')
    elsif !options[:subject].nil? && !options[:standard].nil?
      where('act_master_id = ? AND act_subject_id = ? AND is_active', options[:standard].id, options[:subject].id).order('pos')
    else
      []
    end
  end

  def self.strands
    where('is_active').order('pos ASC')
  end

  def self.strands_for_subject(subject)
    where('act_subject_id = ? AND is_active', subject.id).order('pos ASC') rescue []
  end

  def self.for_standard_and_subject(standard, subject)
    subj = subject.class.to_s == 'Fixnum' ? (ActSubject.find_by_id(subject) rescue nil) : subject
    std = standard.class.to_s == 'Fixnum' ? (ActMaster.find_by_id(standard) rescue nil) : standard
    (subj.nil? || std.nil?) ? [] : where('act_master_id = ? && act_subject_id = ? && is_active', std.id, subj.id).order('pos ASC')
  end

  def self.all_for_standard_and_subject(standard, subject)
    subj = subject.class.to_s == 'Fixnum' ? (ActSubject.find_by_id(subject) rescue nil) : subject
    std = standard.class.to_s == 'Fixnum' ? (ActMaster.find_by_id(standard) rescue nil) : standard
    (subj.nil? || std.nil?) ? [] : where('act_master_id = ? && act_subject_id = ?', std.id, subj.id).order('pos ASC')
  end
  def self.first_for_standard_and_subject(standard, subject)
    subj = subject.class.to_s == 'Fixnum' ? (ActSubject.find_by_id(subject) rescue nil) : subject
    std = standard.class.to_s == 'Fixnum' ? (ActMaster.find_by_id(standard) rescue nil) : standard
    (subj.nil? || std.nil?) ? nil : where('act_master_id = ? && act_subject_id = ? && is_active', std.id, subj.id).first
  end

  def active?
    self.is_active
  end

  def destroyable?
    !self.active? && self.act_questions.empty?
  end

  def self.active
    where('is_active').order('pos ASC')
  end

  def standard
    self.act_master
  end

  def subject_area
    self.act_subject.nil? ? nil : self.act_subject
  end

  def assessments
    self.act_assessments
  end

  def self.abbrev_string
    where('is_active').map{|s| s.abbrev.upcase}.join(', ')
  end
end
