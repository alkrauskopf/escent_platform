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

 
  named_scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  named_scope :for_standard_and_subject, lambda{|standard, subject| {:conditions => ["act_subject_id = ? && act_master_id = ? ", subject.id, standard.id]}} 
  named_scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ?", subject.id]}} 
    
end
