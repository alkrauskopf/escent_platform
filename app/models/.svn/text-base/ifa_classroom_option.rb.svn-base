class IfaClassroomOption < ActiveRecord::Base



  include PublicPersona

  belongs_to :classroom
  belongs_to :act_master
  belongs_to :act_subject
  
  named_scope :notify_on, :conditions => { :is_ifa_notify => true }
  
end
