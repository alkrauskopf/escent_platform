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

  named_scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  named_scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  named_scope :for_subject_no_na, lambda{|subject| {:conditions => ["act_subject_id = ? && upper_score > ?", subject.id, 0]}}
  named_scope :na, {:conditions => ["upper_score = ? ", 0]}
  named_scope :no_na, {:conditions => ["upper_score > ?", 0]}
  named_scope :for_subject_sms, lambda{|subject, sms| {:conditions => ["act_subject_id = ? AND upper_score >= ? AND lower_score <= ?", subject.id, sms, sms]}}

  named_scope :for_standard_and_subject, lambda{|standard, subject| {:conditions => ["act_subject_id = ? && act_master_id = ? ", subject.id, standard.id]}} 
end
