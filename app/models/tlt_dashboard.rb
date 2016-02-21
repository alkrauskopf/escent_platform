class TltDashboard < ActiveRecord::Base
  include PublicPersona
   
  belongs_to :tlt_session
  belongs_to :user
  belongs_to :tracker, :class_name => 'User', :foreign_key => "tracker_id"
  belongs_to :classroom
  belongs_to :topic
  belongs_to :organization
  belongs_to :tl_activity_type
  belongs_to :tl_activity_type_task
  belongs_to :subject_area

  scope :for_activity, lambda{|activity| {:conditions => ["tl_activity_type_id = ? ", activity.id], :order => "duration_secs ASC"}}
  scope :for_task, lambda{|task| {:conditions => ["tl_activity_type_task_id = ? ", task.id], :order => "duration_secs ASC"}}
  scope :for_organization, lambda{|org| {:conditions => ["organization_id = ? ", org.id], :order => "duration_secs ASC"}}
  scope :for_subject, lambda{|sub| {:conditions => ["subject_area_id = ? ", subj.id], :order => "duration_secs ASC"}}
  scope :since_date, lambda{|begin_date| {:conditions => ["created_at >= ? ", begin_date], :order => "duration_secs ASC"}}

end
