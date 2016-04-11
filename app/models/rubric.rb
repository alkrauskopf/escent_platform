class Rubric < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :scope, :polymorphic => true

  has_many :elt_case_indicators
  has_many :elt_plans

  scope :active, :conditions => ["is_active"], :order => "position"
  scope :lacking, :conditions => ["abbrev = ?", "L"]
  scope :proficient, :conditions => ["abbrev = ?", "P"]
  scope :emerging, :conditions => ["abbrev = ?", "E"]
  scope :exemplary, :conditions => ["abbrev = ?", "X"]
  scope :by_score, :order => "score"

  validates_numericality_of :score, :greater_than_or_equal_to => 0, :message => 'must >= 0.  '
  validates_numericality_of :position, :greater_than_or_equal_to => 0, :message => 'must >= 0.  '
  validates_presence_of :name
  validates_presence_of :abbrev
  
  def submitted_indicators_for_element(element)
    self.elt_case_indicators.select{|i| i.elt_case && i.elt_case.submitted? && i.elt_indicator.elt_element_id == element.id} 
  end

  def active?
    self.is_active
  end

  def activity
    self.scope
  end
end
