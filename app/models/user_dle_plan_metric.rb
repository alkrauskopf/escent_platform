class UserDlePlanMetric < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :user_dle_plan
  belongs_to :dle_metric

    scope :for_metric,  lambda{|metric | {:conditions => ["dle_metric_id = ?", metric.id]}}
end
