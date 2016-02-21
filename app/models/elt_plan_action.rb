class EltPlanAction < ActiveRecord::Base
  belongs_to :scope, :polymorphic => true
  belongs_to :elt_plan
  belongs_to :rubric

  scope :for_entity, lambda{|entity| {:conditions => ["scope_type = ? AND scope_id = ?", entity.class.to_s, entity.id]}}
  scope :for_scope, lambda{|scope_type, scope_id| {:conditions => ["scope_type = ? AND scope_id = ?", scope_type, scope_id]}}

end
