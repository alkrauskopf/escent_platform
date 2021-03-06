class EltCaseIndicator < ActiveRecord::Base

  include PublicPersona

  belongs_to :elt_case
  belongs_to :elt_indicator  
  belongs_to :rubric

  has_one :elt_element, :through => :elt_indicator

  scope :for_indicator, lambda{|ind| {:conditions => ["elt_indicator_id = ?", ind.id]}}
  scope :for_rubric, lambda{|rub| {:conditions => ["rubric_id = ?", rub.id]}}
  scope :for_case, lambda{|elt_case| {:conditions => ["elt_case_id = ?", elt_case.id]}}
  scope :rated, :conditions => [ "rubric_id IS NOT NULL" ]
  scope :not_rated, :conditions => [ "rubric_id IS NULL" ]
  scope :any, :include => :elt_case, :conditions => ["elt_cases.is_final = ? || elt_cases.is_final = ?", false, true]
  scope :final, :include => :elt_case, :conditions => [" elt_cases.is_final = ?", true]
  scope :for_org_type, lambda{|org_type| {:include => [:elt_case => :organization], :conditions => ["elt_cases.organization.organization_type_id  = ?", org_type.id]}}
  scope :for_element, lambda{|element| {:include => :elt_indicator, :conditions => ["elt_indicators.elt_element_id = ?", element.id]}}
  scope :final_for_cycle, lambda{|cycle| {:include => :elt_case, :conditions => ["elt_cases.elt_cycle_id = ? AND elt_cases.is_final = ?", cycle.id, true]}}
  scope :for_cycle, lambda{|cycle| {:include => :elt_case, :conditions => ["elt_cases.elt_cycle_id = ?", cycle.id]}}
  scope :for_org, lambda{|org| {:include => :elt_case, :conditions => ["elt_cases.organization_id = ?", org.id]}}
  scope :for_org_cycle, lambda{|org,cycle| {:include => :elt_case, :conditions => ["elt_cases.elt_cycle_id = ? AND elt_cases.organization_id = ?", cycle.id, org.id]}}
  scope :with_note, :conditions => ["note != ? || note IS NOT NULL", '']
  scope :for_element_rubric, lambda{|element, rub| {:include => :elt_indicator, :conditions => ["elt_indicators.elt_element_id = ? && rubric.id = ?", element.id, rub.id]}}

  def rubric?
    self.rubric.nil? ? false:true
  end
  
  def score
    self.rubric? ? self.rubric.score : nil
  end  

  def activity
    self.elt_indicator.elt_type
  end

  def key_finding?
    self.is_key
  end

  def self.key_findings
    where('is_key')
  end

  def self.kb_findings(rubric, element, org_type, activity, options={})
    findings = EltCaseIndicator.all(:include => [:elt_indicator, :elt_case => :organization], :conditions => ['elt_cases.elt_type_id = ? AND elt_indicators.elt_element_id = ? AND rubric_id = ?', activity.id, element.id, rubric.id]).select{|f| !f.elt_case.organization.nil? && f.elt_case.organization.organization_type_id == org_type.id}
    if options[:key_only]
      !findings.select{|f| f.key_finding?}
    end
    findings
  end
end
