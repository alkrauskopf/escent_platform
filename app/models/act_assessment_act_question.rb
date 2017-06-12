class ActAssessmentActQuestion < ActiveRecord::Base
  include PublicPersona

  belongs_to :act_assessment
  belongs_to :act_question
  
  has_many :act_assessments
  has_many :act_questions
  
  acts_as_list :scope => :act_assessment

  scope :for_question, lambda{|question| {:conditions => ["act_question_id = ?", question.id]}}
  scope :with_greater_position, lambda{|position| {:conditions => ["position >= ?", position]}}
  scope :for_assessment, lambda{|assessment| {:conditions => ["act_assessment_id = ?", assessment.id]}}

end
