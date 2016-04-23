class DleCycle < ActiveRecord::Base

  belongs_to :tlt_survey_type
  has_many :user_dle_plans, :dependent => :destroy
  has_many :dle_cycle_orgs, :dependent => :destroy
  
  scope :for_stage,  lambda{|stage | {:conditions => ["stage = ?", stage]}}
  scope :all_by_stage, :order => 'stage'
  scope :stage_one,  :conditions => ["stage = ? ", 1]
  scope :next_stage,  lambda{|stage | {:conditions => ["stage = ?", stage+1]}}



def for_org(org)
  org.dle_cycle_orgs.for_dle_cycle(self).first rescue nil
end



end
