class ItlSummaryStrategy < ActiveRecord::Base

  belongs_to :itl_summary
  belongs_to :tl_activity_type_task

  named_scope :for_strategy, lambda{|task| {:conditions => ["tl_activity_type_task_id = ? ", task.id]}}

  
end
