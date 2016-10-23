class ActScoreRange < ActiveRecord::Base

  include PublicPersona

  belongs_to :act_master
  belongs_to :act_subject
  
  has_many :act_benches, :dependent => :destroy
  has_many :contents


  has_many :act_question_act_score_ranges, :dependent => :destroy
  has_many :act_questions, :through => :act_question_act_score_ranges  

  has_many :act_rel_reading_act_score_ranges, :dependent => :destroy
  has_many :act_rel_readings, :through => :act_rel_reading_act_score_ranges   
  has_many :ifa_question_performances
  
  has_many :act_score_range_topics, :dependent => :destroy
  has_many :topics, :through => :act_score_range_topics

  scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id],:order => "upper_score"}}
  scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  scope :for_subject_no_na, lambda{|subject| {:conditions => ["act_subject_id = ? && upper_score > ?", subject.id, 0]}}
  scope :na, {:conditions => ["upper_score = ? ", 0]}
  scope :no_na, {:conditions => ["upper_score > ?", 0]}
  scope :for_subject_sms, lambda{|subject, sms| {:conditions => ["act_subject_id = ? AND upper_score >= ? AND lower_score <= ?", subject.id, sms, sms]}}

#  scope :for_standard_and_subject, lambda{|standard, subject| {:conditions => ["act_subject_id = ? && act_master_id = ? ", subject.id, standard.id],:order => "upper_score"}}
#  scope :for_standardstring_and_subject, lambda{|standard, subject| {:conditions => ["act_subject_id = ? && standard = ? ", subject.id, standard],:order => "upper_score"}}

  def self.standard_subject_greater_than_upper(standard, subject, upper)
    where('act_subject_id = ? AND act_master_id = ? AND upper_score > ?', subject.id, standard.id, upper).order('upper_score')
  end

  def self.for_subject_id(subject_id)
    where('act_subject_id = ?', subject_id)
  end

  def self.for_standardstring_and_subject(standard, subject)
    subj = subject.class.to_s == 'Fixnum' ? (ActSubject.find_by_id(subject) rescue nil) : subject
    subj.nil? ? [] : where('standard = ? && act_subject_id = ?',standard, subj.id).order('upper_score ASC')
  end

  def self.for_standard_and_subject(standard, subject)
    subj = subject.class.to_s == 'Fixnum' ? (ActSubject.find_by_id(subject) rescue nil) : subject
    std = standard.class.to_s == 'Fixnum' ? (ActMaster.find_by_id(standard) rescue nil) : standard
    (subj.nil? || std.nil?) ? [] : where('act_master_id = ? && act_subject_id = ?',std.id, subj.id).order('upper_score ASC')
  end

end
