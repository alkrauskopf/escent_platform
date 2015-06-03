class ClientAssignment < ActiveRecord::Base

  belongs_to :consultant, :class_name => 'User', :foreign_key => "user_id"
  
  belongs_to :organization_client

  named_scope :for_consultant, lambda{|consultant| {:conditions => ["user_id = ? ", consultant.id]}}


end
