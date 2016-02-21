class OrganizationDleMetric < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :organization
  belongs_to :dle_metric

  scope :for_metric,  lambda{|metric | {:conditions => ["dle_metric_id = ?", metric.id]}}

end
