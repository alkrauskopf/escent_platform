class ActQuestionActStandard < ActiveRecord::Base
  include PublicPersona

  belongs_to :act_standard
  belongs_to :act_question
  
  has_many :act_standards
  has_many :act_questions
  
  named_scope :for_strand, lambda{|strand| {:conditions => ["act_standard_id = ? ", strand.id]}}

end
