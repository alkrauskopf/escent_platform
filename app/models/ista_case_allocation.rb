class IstaCaseAllocation < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :activity, :polymorphic => true
  belongs_to :ista_case
  belongs_to :ista_step
  belongs_to :ista_group

  scope :for_step, lambda{|step| {:conditions => ["ista_step_id = ? ", step.id]}}
  scope :for_group, lambda{|group| {:conditions => ["ista_group_id = ? ", group.id]}}


end
