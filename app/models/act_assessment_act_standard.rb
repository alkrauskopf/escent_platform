class ActAssessmentActStandard < ActiveRecord::Base
  attr_accessible :act_assessment_id, :act_standard_id

  belongs_to :act_assessment
  belongs_to :act_standard

  has_many :act_assessments
  has_many :act_standards

  def self.for_strand(strand)
    strand.nil? ? [] : where('act_standard_id = ?', strand.id)
  end

  def self.for_assessment(assessment)
    assessment.nil? ? [] : where('act_assessment_id = ?', assessment.id)
  end

end
