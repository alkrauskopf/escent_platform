class EltCaseNote < ActiveRecord::Base
  
  belongs_to :elt_case
  belongs_to :elt_element
  belongs_to :rubric
  
  scope :for_element, lambda{|el| {:conditions => ["elt_element_id = ?", el.id]}}

  def self.for_rubric(rub)
    where('rubric_id = ?', rub.id)
  end

  def rubric?
    self.rubric.nil? ? false:true
  end

  def score
    self.rubric? ? self.rubric.score : nil
  end
end
