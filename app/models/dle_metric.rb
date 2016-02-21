class DleMetric < ActiveRecord::Base
  include PublicPersona
  
  has_many :organization_dle_metrics, :dependent => :destroy
  has_many :organizations, :through => :organization_dle_metrics
  
  has_many :user_dle_plan_metrics, :dependent => :destroy
  has_many :user_dle_plan, :through => :user_dle_plan_metrics

  scope :all_by_position, :order => "position"

end
