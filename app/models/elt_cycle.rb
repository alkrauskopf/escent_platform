class EltCycle < ActiveRecord::Base
  include PublicPersona

  belongs_to :organization

  has_many :elt_cases, :dependent => :destroy
  has_many :schools, :through=> :elt_cases, :source=>:organization, :uniq=>true
  has_many :elt_org_options
  has_many :elt_cycle_summaries
  has_many :current_schools, :through=> :elt_org_options, :source=>:organization, :uniq=>true
    
  has_many :elt_cycle_activities, :dependent => :destroy
  has_many :activities, :through => :elt_cycle_activities, :source => :elt_type
  has_many :elt_cycle_elements, :dependent => :destroy
  has_many :elements, :through => :elt_cycle_elements, :source => :elt_element, :uniq=>true

  has_many :survey_schedules, :as => :entity, :dependent => :destroy  
  has_many :elt_plans, :dependent => :destroy
  
  validates_presence_of :name
        
  scope :active, :conditions => ["is_active"], :order => 'begin_date DESC'
  scope :all,  :conditions => {:is_delete => false}, :order => 'begin_date DESC'
  scope :available,  :conditions => {:is_delete => false}, :order => 'begin_date DESC'
  scope :deleted,  :conditions => {:is_delete => true}, :order => 'created_at DESC'

  def active?
    self.is_active
  end

  def deletable?
    !self.active? && self.current_schools.empty?
  end

  def provider
    self.organization ? self.organization : nil
  end

  def master_activity
    self.activities.masters.first rescue nil
  end

  def client_feedback_surveys
    app = CoopApp.elt
    self.survey_schedules.for_audience(app.tlt_survey_audiences.client.first).for_type(app.tlt_survey_types.feedback.first) rescue []
  end   
  
  def school_survey_available?
    app = CoopApp.elt
    !self.organization.tlt_survey_questions.for_audience(app.tlt_survey_audiences.client.first).for_type(app.tlt_survey_types.feedback.first).active.empty?
  end  
 
  def school_survey_active?
    !self.survey_schedules.active.empty?
  end 
  
  def school_survey_expired?
    false
  end 
  
  def finalized_schools
    self.elt_cases.final.collect{|c| c.organization}.compact.flatten.uniq.sort_by{|s| s.name}
  end
  
  def participated_schools
    self.elt_cases.collect{|c| c.organization}.compact.flatten.uniq.sort_by{|s| s.name}
  end
  
  def finalized_case_indicators_for_indicator(indicator)
    self.elt_cases.collect{|c| c.elt_case_indicators.for_indicator(indicator)}.compact.flatten.uniq
  end

  def finalized_scored_indicators_for_indicator(indicator)
    self.finalized_case_indicators_for_indicator(indicator).select{|ci| ci.rubric}
  end
   
  def scores_for_indicator(indicator)
    self.finalized_scored_indicators_for_indicator(indicator).collect{|ci| ci.rubric.score}.join(", ")
  end

  def finalized_case_indicators_for_element(element)
    self.elt_cases.collect{|c| c.elt_case_indicators.for_element(element)}.compact.flatten.uniq
  end

  def rubrics_for_element(element)
    self.finalized_case_indicators_for_element(element).collect{|ci| ci.rubric}.compact.flatten
  end

  def case_indicators_for_org_element(element, org)
    org.elt_cases.for_cycle(self).collect{|c| c.elt_case_indicators.for_element(element)}.compact.flatten
  end

  def rubrics_for_element_org(element, org)
    self.case_indicators_for_org_element(element, org).collect{|ci| ci.rubric}.compact
  end

  def average_score_for_indicator(indicator)
    self.finalized_scored_indicators_for_indicator(indicator).size == 0 ? 0 : self.finalized_scored_indicators_for_indicator(indicator).collect{|ci| ci.rubric}.sum{|r| r.score}.to_f/self.finalized_scored_indicators_for_indicator(indicator).size.to_f
  end
  
  def summary_for_indicator(indicator)
    self.elt_cycle_summaries.for_indicator(indicator).empty? ? nil : self.elt_cycle_summaries.for_indicator(indicator).first
  end

  def standards
    self.elements.collect{|e| e.standard}.compact.uniq
  end
  
end
