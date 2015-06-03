class IfaOrgOptionActMaster < ActiveRecord::Base


  belongs_to :ifa_org_option
  belongs_to :act_master

  named_scope :for_master, lambda{|mstr| {:conditions => ["act_master_id = ? ", mstr.id]}}


end
