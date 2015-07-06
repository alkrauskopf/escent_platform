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

  named_scope :active, :conditions => ["is_active"]
  named_scope :interviews, :conditions => ["elt_activity_type_id = ?", 2]
  named_scope :observations, :conditions => ["elt_activity_type_id = ?", 1]
  named_scope :self_assessments, :conditions => ["elt_activity_type_id = ?", 3]
  named_scope :masters, :conditions => ["is_master"]
  named_scope :provider_only, :conditions => ["provider_only"], :order => "position"
  named_scope :for_client, :conditions => ["provider_only = ?", false], :order => "position"
  named_scope :shareable, :conditions => ["rubric_id IS NOT NULL"], :order => "position"
  named_scope :reportable, :conditions => ["is_reportable"]

  named_scope :all, :order => "position"
  
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

  def copy_indicators(source_activity)
    source_activity.elt_indicators.each do |source_ind|
      new_indicator = source_ind.clone
      new_indicator.is_active = false
      new_indicator.elt_type_id = self.id
      new_indicator.save
      source_ind.support_indicators.each do |sup_indicator|
        sup_indicator.lookfors << new_indicator
      end
    end
  end
end
