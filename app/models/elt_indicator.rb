class EltIndicator < ActiveRecord::Base

  include PublicPersona

  acts_as_tree
    
  belongs_to :elt_element
  belongs_to :elt_type

  has_many :elt_case_indicators, :dependent => :destroy
  has_many :elt_related_indicators, :dependent => :destroy
#  has_many :lookfors, :through => :elt_related_indicators, :source=> :lookfor, :uniq=>true
  has_many :elt_indicator_lookfors, :dependent => :destroy
  has_many :elt_cycle_summaries
  has_many :elt_plan_actions, :as => :scope, :dependent => :destroy
  has_many :elt_std_indicators,:through => :elt_related_indicators, :uniq=>true
  
  validates_presence_of :indicator, :message => 'Must Define Indicator' 
  validates_numericality_of :position, :greater_than => 0, :message => 'must > 0.  '
  validates_numericality_of :weight, :greater_than_or_equal_to => 1, :less_than_or_equal_tp => 10,  :message => 'Must Be Between 1 & 10.'
  validates_presence_of :elt_type_id, :message => 'Element Not Defined'
  validates_presence_of :elt_element_id, :message => 'Element Not Defined'
      
  scope :active, :conditions => ["is_active"], :order => 'position ASC'
  scope :inactive, :conditions => ["!is_active"], :order => 'position ASC'
  scope :for_activity, lambda{|activity| {:conditions => ["elt_type_id = ? ", activity.id]}}
  scope :for_element, lambda{|element| {:conditions => ["elt_element_id = ? ", element.id]}}
  scope :by_position, :order => 'position ASC'
  scope :all_parents,   :conditions => ["parent_id IS NULL"], :order=>'name'


  def active?
    self.is_active
  end
  
  def all_children
    (self.children + self.children.collect{|child| child.children}).flatten
  end
  
  def all_active_children
    (self.children + self.children.collect{|child| child.children}).flatten.select{|i| i.is_active}
  end
 
  def child?
    !self.parent_id.nil? && self.parent
  end

  def support_indicators
   self.supported_std_indicators.sort_by{|i| i.position}
 #   EltRelatedIndicator.find(:all, :conditions =>["related_indicator_id = ?", self.id]).collect{|i| i.elt_indicator}.sort_by{|i| [i.elt_element.abbrev, i.position]}
  end

  def supported_std_indicators
    self.elt_std_indicators.by_element
  end

  def case_findings(elt_case)
    self.elt_case_indicators.for_case(elt_case)
  end

  def self.cycle_findings(cycle)
    self.collect{|i| i.elt_case_indicators.for_cycle(cycle)}.flatten
  end

  def self.destroy_disabled!(activity,element)
    EltIndicator.for_activity(activity).for_element(element).inactive.destroy_all
  end

  def supporting_indicatorsx(cycle)
    self.lookfors.select{ |lf| cycle.activities.include?(lf.elt_type) }.compact
  end

  def supporting_evidences(cycle, org)
    evidences = []
    self.supporting_indicatorsx(cycle).each do |indicator|
      evidences << indicator.elt_case_indicators.for_org(org).for_cycle(cycle).flatten
    end
    evidences.flatten.compact
  end

  def element
    self.elt_element.nil? ? nil : self.elt_element
  end

  def standard_indicators
    self.element.nil? ? [] : self.element.indicators.active
  end

  def framework
    self.elt_type.elt_framework rescue nil
  end

  def master_activity
    self.framework.elt_types.masters.first rescue nil
  end

  def master_activity_active
    self.framework.elt_types.masters.active.first rescue nil
  end

  def final_scored_indicators_for_cycle(cycle)
    self.elt_case_indicators.final_for_cycle(cycle).select{|ci| ci.rubric}
  end

  def final_average_score_for_cycle(cycle)
    self.final_scored_indicators_for_cycle(cycle).size == 0 ? 0 : self.final_scored_indicators_for_cycle(cycle).collect{|ci| ci.rubric}.sum{|r| r.score}.to_f/self.final_scored_indicators_for_cycle(cycle).size.to_f
  end
  
  def scored_indicators_for_cycle(cycle)
    self.elt_case_indicators.for_cycle(cycle).select{|ci| ci.rubric}
  end

  def average_score_for_cycle(cycle)
    self.scored_indicators_for_cycle(cycle).size == 0 ? 0 : self.scored_indicators_for_cycle(cycle).collect{|ci| ci.rubric}.sum{|r| r.score}.to_f/self.scored_indicators_for_cycle(cycle).size.to_f
  end
  
  def final_scored_indicators
    self.elt_case_indicators.final.select{|ci| ci.rubric}
  end

  def final_average_score
    self.final_scored_indicators.size == 0 ? 0 : self.final_scored_indicators.collect{|ci| ci.rubric}.sum{|r| r.score}.to_f/self.final_scored_indicators.size.to_f
  end

  def scored_indicators
    self.elt_case_indicators.select{|ci| ci.rubric}
  end

  def average_score
    self.scored_indicators.size == 0 ? 0 : self.scored_indicators.collect{|ci| ci.rubric}.sum{|r| r.score}.to_f/self.scored_indicators.size.to_f
  end
  
  def final_scored_indicators_for_org_cycle(org,cycle)
    self.elt_case_indicators.for_org(org).final_for_cycle(cycle).select{|ci| ci.rubric}
  end

  def final_average_score_for_org_cycle(org, cycle)
    self.final_scored_indicators_for_org_cycle(org, cycle).size == 0 ? 0 : self.final_scored_indicators_for_org_cycle(org, cycle).collect{|ci| ci.rubric}.sum{|r| r.score}.to_f/self.final_scored_indicators_for_org_cycle(org, cycle).size.to_f
  end  
  
  def scored_indicators_for_org_cycle(org,cycle)
    self.elt_case_indicators.for_org(org).for_cycle(cycle).select{|ci| ci.rubric}
  end

  def average_score_for_org_cycle(org, cycle)
    self.scored_indicators_for_org_cycle(org, cycle).size == 0 ? 0 : self.scored_indicators_for_org_cycle(org, cycle).collect{|ci| ci.rubric}.sum{|r| r.score}.to_f/self.scored_indicators_for_org_cycle(org, cycle).size.to_f
  end

  def cycle_summaries(cycle)
    if cycle.nil?
      self.elt_cycle_summaries.active
    else
      cycle.elt_cycle_summaries.for_indicator(self).active
    end
  end

  def cycle_summary_avg_score(cycle)
    total_score = self.cycle_summaries(cycle).collect{|cs| cs.score_total}.sum.to_f
    total_count = self.cycle_summaries(cycle).collect{|cs| cs.score_count}.sum.to_f
    avg_score = total_count == 0.0 ? 0.0 : total_score/total_count
  end

end
