class EltRubric < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :elt_type
  
  has_many :elt_rubric_criterias
  has_many :elt_case_indicators

  named_scope :lacking, :conditions => ["abbrev = ?", "L"]
  named_scope :proficient, :conditions => ["abbrev = ?", "P"]
  named_scope :emerging, :conditions => ["abbrev = ?", "E"]
  named_scope :exemplary, :conditions => ["abbrev = ?", "X"]  

  validates_numericality_of :score, :greater_than_or_equal_to => 0, :message => 'must >= 0.  '
  
  def submitted_indicators_for_element(element)
    self.elt_case_indicators.select{|i| i.elt_case && i.elt_case.submitted? && i.elt_indicator.elt_element_id == element.id} 
  end
  
end
