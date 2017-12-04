class IfaPlanMetricCell < ActiveRecord::Base
  attr_accessible :achieved, :cell, :evidences, :ifa_plan_metric_id, :in_process, :plans, :remarks

  include PublicPersona

  belongs_to :ifa_plan_metric

  def self.in_cell(cell_name)
    where('cell = ?', cell_name).last rescue nil
  end
end
