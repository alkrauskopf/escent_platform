class ActAssessmentClassroom < ActiveRecord::Base

  belongs_to :act_assessment
  belongs_to :classroom
  
  has_many :act_assessments
  has_many :classrooms
  
  acts_as_list :scope => :act_assessment

  def self.for_classroom(classroom)
    where('classroom_id = ?', classroom.id)
  end

  def self.for_assessment(assessment)
    where('act_assessment_id = ?', assessment.id)
  end

end
