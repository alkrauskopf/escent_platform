class DleCycle < ActiveRecord::Base

  belongs_to :tlt_survey_type
  has_many :user_dle_plans, :dependent => :destroy
  has_many :dle_cycle_orgs, :dependent => :destroy
  
  named_scope :for_stage,  lambda{|stage | {:conditions => ["stage = ?", stage]}}
  named_scope :all_by_stage, :order => 'stage'
  named_scope :stage_one,  :conditions => ["stage = ? ", 1]   
  named_scope :next_stage,  lambda{|stage | {:conditions => ["stage = ?", stage+1]}}



def for_org(org)
  DleCycleOrg.find(:first, :conditions=>["dle_cycle_id = ? AND organization_id = ?", self.id, org.id]) rescue nil
end



end
