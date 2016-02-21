class IstaStep < ActiveRecord::Base
  include PublicPersona
  
  has_many :ista_activities
  has_many :ista_cases
  
  has_many   :ista_case_allocations

  scope :active, :conditions => ["is_active"], :order => 'step_number'
  scope :step_1, :conditions => ["is_active && step_number = ?", 1]
  scope :step_2, :conditions => ["is_active && step_number = ?", 2]
  scope :step_3, :conditions => ["is_active && step_number = ?", 3]
  scope :step_4, :conditions => ["is_active && step_number = ?", 4]
  scope :step_5, :conditions => ["is_active && step_number = ?", 5]
  scope :next_step, lambda{|step| {:conditions => ["is_active && step_number = ?", step.step_number + 1]}}

end
