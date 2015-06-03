class ActAssessmentClassroom < ActiveRecord::Base

  belongs_to :act_assessment
  belongs_to :classroom
  
  has_many :act_assessments
  has_many :classrooms
  
  acts_as_list :scope => :act_assessment

end
