class ReportedAbuse < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  belongs_to :user
  belongs_to :organization  
  
  AbuseTypes = ['spam', 'offensive']
  
  def self.report_abuse(options)
    
  end
  
end
