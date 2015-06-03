class IfaOrgOption < ActiveRecord::Base


  include PublicPersona

  belongs_to :organization
  has_many :ifa_org_option_act_masters, :dependent => :destroy
  has_many :act_masters, :through => :ifa_org_option_act_masters

  validates_presence_of :sms_calc_cycle
  validates_presence_of :days_til_repeat
  validates_presence_of :sms_h_threshold
  validates_presence_of :pct_correct_red
  validates_presence_of :pct_correct_green
 
  validates_numericality_of :days_til_repeat, :greater_than_or_equal_to => 0
  
end
