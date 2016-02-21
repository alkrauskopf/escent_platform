class ActSubmissionSms < ActiveRecord::Base

  include PublicPersona

  belongs_to :act_master
  belongs_to :act_submission
  
  scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}


end
