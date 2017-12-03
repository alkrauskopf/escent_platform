class IfaPlanMetricCell < ActiveRecord::Base
  attr_accessible :acheived, :cell, :evidences, :ifa_plan_metric_id, :in_process, :plans, :remarks

  include PublicPersona

  belongs_to :ifa_plan_metric

end
