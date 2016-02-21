class ItlOrgOptionFilter < ActiveRecord::Base

  belongs_to  :tl_activity_type_task
  belongs_to  :itl_org_option

  scope :for_task, lambda{|task| {:conditions => ["tl_activity_type_task_id = ? ", task.id]}}

end
