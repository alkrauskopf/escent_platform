class IfaUserBaselineScore < ActiveRecord::Base

  include PublicPersona

  belongs_to :user
  belongs_to :act_master  
  belongs_to :act_subject

  named_scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  named_scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}


end
