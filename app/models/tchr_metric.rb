class TchrMetric < ActiveRecord::Base

  include PublicPersona

  has_many :tchr_option_metrics, :dependent => :destroy
  has_many :tchr_options, :through => :tchr_option_metrics


  scope :for_teacher, :conditions => { :for_teacher => true }
  scope :for_classroom, :conditions => { :for_classroom => true }
  scope :by_month, :conditions => { :by_month => true }
  
end
