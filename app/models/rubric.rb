class Rubric < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :scope, :polymorphic => true

  has_many :elt_case_indicators
  has_many :elt_plans

  named_scope :active, :conditions => ["is_active"], :order => "position"
  named_scope :lacking, :conditions => ["abbrev = ?", "L"]
  named_scope :proficient, :conditions => ["abbrev = ?", "P"]
  named_scope :emerging, :conditions => ["abbrev = ?", "E"]
  named_scope :exemplary, :conditions => ["abbrev = ?", "X"]  
  named_scope :by_score, :order => "score"

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
  
end
