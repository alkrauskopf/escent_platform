class EltCaseIndicator < ActiveRecord::Base

  include PublicPersona

  belongs_to :elt_case
  belongs_to :elt_indicator  
  belongs_to :rubric

  has_one :elt_element, :through => :elt_indicator

  named_scope :for_indicator, lambda{|ind| {:conditions => ["elt_indicator_id = ?", ind.id]}}
  named_scope :for_rubric, lambda{|rub| {:conditions => ["rubric_id = ?", rub.id]}}
  named_scope :for_case, lambda{|elt_case| {:conditions => ["elt_case_id = ?", elt_case.id]}}
  named_scope :rated, :conditions => [ "rubric_id IS NOT NULL" ]
  named_scope :not_rated, :conditions => [ "rubric_id IS NULL" ]
  named_scope :any, :include => :elt_case, :conditions => ["elt_cases.is_final = ? || elt_cases.is_final = ?", false, true]
  named_scope :final, :include => :elt_case, :conditions => [" elt_cases.is_final = ?", true]
  named_scope :for_org_type, lambda{|org_type| {:include => [:elt_case => :organization], :conditions => ["elt_cases.organization.organization_type_id  = ?", org_type.id]}}
  named_scope :for_element, lambda{|element| {:include => :elt_indicator, :conditions => ["elt_indicators.elt_element_id = ?", element.id]}}
  named_scope :final_for_cycle, lambda{|cycle| {:include => :elt_case, :conditions => ["elt_cases.elt_cycle_id = ? AND elt_cases.is_final = ?", cycle.id, true]}}
  named_scope :for_cycle, lambda{|cycle| {:include => :elt_case, :conditions => ["elt_cases.elt_cycle_id = ?", cycle.id]}}
  named_scope :for_org, lambda{|org| {:include => :elt_case, :conditions => ["elt_cases.organization_id = ?", org.id]}}
  named_scope :with_note, :conditions => ["note != ? || note IS NOT NULL", '']
  named_scope :for_element_rubric, lambda{|element, rub| {:include => :elt_indicator, :conditions => ["elt_indicators.elt_element_id = ? && rubric.id = ?", element.id, rub.id]}}


  
  def rubric?
    self.rubric
  end
  
  def score
    self.rubric? ? self.rubric.score : nil
  end  

  def activity
    self.elt_indicator.elt_type
  end

end
