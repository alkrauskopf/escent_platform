class EltActivityType < ActiveRecord::Base

  has_many :elt_types
  
  named_scope :active, :conditions => ["is_active"]
  named_scope :interviews, :conditions => ["name = ?", "Interview"]
  named_scope :observations, :conditions => ["name = ?", "Observation"]
  named_scope :self_assessments, :conditions => ["name = ?", "Self Assess"]

  
  def active?
    self.is_active
  end

end
