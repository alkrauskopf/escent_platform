class TltSessionLog < ActiveRecord::Base
  include PublicPersona
  
  
  belongs_to :tlt_session
  belongs_to :tl_activity_type_task

 
  
  named_scope :active, :conditions => { :is_active => true} 
  named_scope :for_task, lambda{|task| {:conditions => ["tl_activity_type_task_id = ? ", task.id]}}
  named_scope :with_involvement, :conditions => {:conditions => ["involve_score > ? ", 0]}
  named_scope :with_impact, :conditions => {:conditions => ["impact_score > ? ", 0]}



  def log_task_method_tasks
    self.tl_activity_type_task.tl_activity_type.app_method.tl_activity_types.collect{|t| t.tl_activity_type_tasks.enabled}.flatten
  end
end
