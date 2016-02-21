class EltActivityType < ActiveRecord::Base

  has_many :elt_types
  
  scope :active, :conditions => ["is_active"]
  scope :interviews, :conditions => ["name = ?", "Interview"]
  scope :observations, :conditions => ["name = ?", "Observation"]
  scope :self_assessments, :conditions => ["name = ?", "Self Assess"]

  
  def active?
    self.is_active
  end

end
