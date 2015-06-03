class TchrOption < ActiveRecord::Base

  include PublicPersona

  belongs_to :user
  
  has_many :tchr_option_metrics, :dependent => :destroy
  has_many :tchr_metrics, :through => :tchr_option_metrics


end
