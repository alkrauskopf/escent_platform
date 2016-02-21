class Status < ActiveRecord::Base

  scope :approval,   :conditions => { :name => "Approved" }


  def self.approved
    @approved ||= self.find_by_name("Approved")
  end
  
  def self.pending_approval
    @pending_approval ||= self.find_by_name("Pending Approval")
  end
  
end
