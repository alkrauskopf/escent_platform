class IstaStep < ActiveRecord::Base
  include PublicPersona
  
  has_many :ista_activities
  has_many :ista_cases
  
  has_many   :ista_case_allocations

  named_scope :active, :conditions => ["is_active"], :order => 'step_number'
  named_scope :step_1, :conditions => ["is_active && step_number = ?", 1]
  named_scope :step_2, :conditions => ["is_active && step_number = ?", 2]
  named_scope :step_3, :conditions => ["is_active && step_number = ?", 3]
  named_scope :step_4, :conditions => ["is_active && step_number = ?", 4]
  named_scope :step_5, :conditions => ["is_active && step_number = ?", 5]
  named_scope :next_step, lambda{|step| {:conditions => ["is_active && step_number = ?", step.step_number + 1]}}

end
