class ActAssessmentActQuestion < ActiveRecord::Base
  include PublicPersona

  belongs_to :act_assessment
  belongs_to :act_question
  
  has_many :act_assessments
  has_many :act_questions
  
  acts_as_list :scope => :act_assessment

  named_scope :for_question, lambda{|question| {:conditions => ["act_question_id = ?", question.id]}} 
  named_scope :with_greater_position, lambda{|position| {:conditions => ["position >= ?", position]}} 

end
