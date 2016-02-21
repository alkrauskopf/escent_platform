class EltType < ActiveRecord::Base

  include PublicPersona
 
  belongs_to :organization
  belongs_to :elt_activity_type
  belongs_to :share_rubric, :class_name=> 'Rubric', :foreign_key => :rubric_id
  belongs_to :elt_framework

  has_many :elt_cases
  has_many :elt_indicators, :dependent => :destroy
  has_many :rubrics, :as => :scope, :order => "position", :dependent => :destroy
  has_many :elements, :through => :elt_indicators, :source => :elt_element, :uniq=>true
  
  has_many :elt_cycle_activities, :dependent => :destroy
  has_many :cycles, :through => :elt_cycle_activities, :source => :elt_cycle
  has_many :elt_cycle_summaries

  scope :active, :conditions => ["is_active"]
  scope :interviews, :conditions => ["elt_activity_type_id = ?", 2]
  scope :observations, :conditions => ["elt_activity_type_id = ?", 1]
  scope :self_assessments, :conditions => ["elt_activity_type_id = ?", 3]
  scope :masters, :conditions => ["is_master"]
  scope :informing, :conditions => ["!is_master"]
  scope :provider_only, :conditions => ["provider_only"], :order => "position"
  scope :for_client, :conditions => ["provider_only = ?", false], :order => "position"
  scope :shareable, :conditions => ["rubric_id IS NOT NULL"], :order => "position"
  scope :reportable, :conditions => ["is_reportable"]

  scope :all, :order => "position"
  scope :all_by_framework, :order => "elt_framework_id"

  validates_presence_of :name
  validates_presence_of :elt_activity_type_id
  validates_numericality_of :position, :greater_than => 0, :message => 'must > 0.  '
  
  def active?
    self.is_active
  end
  
  def master?
    self.is_master
  end
  
  def interview?
    self.elt_activity_type_id == 2
  end
  
  def observation?
    self.elt_activity_type_id == 1
  end
  
  def self_assessment?
    self.elt_activity_type_id == 3
  end

  def rubric?
    self.use_rubric
  end

  def provider_only?
    self.provider_only
  end

  def reportable?
    self.is_reportable
  end

  def collect_subject?
    self.tag_subject
  end

  def collect_grade?
    self.tag_grade
  end
  
  def has_active_indicators?
    !self.elt_indicators.active.empty?
  end
 
  def elements
    self.elt_indicators.collect{|i| i.elt_element}.compact.uniq
  end
 
  def active_elements
    self.elt_indicators.active.collect{|i| i.elt_element}.compact.uniq.select{|e| e.active?}.sort_by{ |e| e.position}
  end

  def activity_type
    self.elt_activity_type ? self.elt_activity_type.name : "Undefined"
  end

  def activity_description
    self.elt_activity_type ? self.elt_activity_type.description : ""
  end

  def max_rubric
    self.rubric? ? self.rubrics.active.by_score.last : nil
  end

  def shareable_rubrics
    self.share_rubric ? self.active_rubrics.select{|r| self.share_rubric.score <= r.score} : []
  end
  
  def active_rubrics
    self.rubric? ? self.rubrics.active : []
  end

  def copy_indicators(source_activity, element, to_element)
    source_activity.elt_indicators.for_element(element).active.each do |source_ind|
      new_indicator = EltIndicator.new
      new_indicator.position = source_ind.position
      new_indicator.weight = source_ind.weight
      new_indicator.indicator = source_ind.indicator
      new_indicator.ind_num = source_ind.ind_num
      new_indicator.parent_id = nil
      new_indicator.is_active = false
      new_indicator.elt_element_id = to_element.id
      if self.elt_indicators << new_indicator
        source_ind.elt_indicator_lookfors.each do |lookfor|
          new_indicator.elt_indicator_lookfors << lookfor
        end
      end
    end
  end

  def informing_indicators(element)
   self.elt_indicators.for_element(element).active.map {|ind| ind.support_indicators.compact }.flatten
  end
end
