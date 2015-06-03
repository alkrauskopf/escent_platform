class ActSnapshot < ActiveRecord::Base

  include PublicPersona
  

  belongs_to :act_subject
  belongs_to :user
  belongs_to :organization
  belongs_to :act_master
  
  named_scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}


end
