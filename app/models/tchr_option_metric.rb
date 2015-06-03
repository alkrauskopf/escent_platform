class TchrOptionMetric < ActiveRecord::Base

  include PublicPersona
  

  belongs_to :tchr_metric
  belongs_to :tchr_option

  
  has_many :tchr_metrics
  has_many :tchr_options

  acts_as_list :scope => :tchr_option
  

end
