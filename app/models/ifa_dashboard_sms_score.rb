class IfaDashboardSmsScore < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :ifa_dashboard
  belongs_to :act_master

  named_scope :for_score_range, lambda{|low_score, high_score| {:conditions => ["sms_finalized >= ? && sms_finalized <= ?", low_score, high_score]}}
  named_scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
end
