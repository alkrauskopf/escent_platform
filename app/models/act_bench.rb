class ActBench < ActiveRecord::Base

  include PublicPersona
  
  
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


 end  




