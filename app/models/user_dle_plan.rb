class UserDlePlan < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :user
  belongs_to :dle_cycle

  has_many :user_dle_plan_metrics, :dependent => :destroy 
  has_many :user_dle_plan_coachings, :dependent => :destroy 
  has_many :tlt_survey_responses, :dependent => :destroy 
  
  has_many   :survey_schedules, :as => :entity, :dependent => :destroy
  
    
  has_attached_file :attach, :path => ":rails_root/public/dle_library/:id/:basename.:extension", :url => "/dle_library/:id/:basename.:extension"

  named_scope :current, :conditions => ["is_current"]
  named_scope :still_open, :conditions => ["date_finalized IS NULL"]
  named_scope :by_plan_number, :order => 'plan'
  named_scope :for_package,  lambda{|id | {:conditions => ["plan = ?", id]}}


  def new_stage
    next_cycle = DleCycle.next_stage(self.dle_cycle.stage).first rescue nil
    new_stage = UserDlePlan.new
    new_stage.cycle_start_date = Date.today
    new_stage.is_current = true
    new_stage.plan = self.plan
    new_stage.dle_cycle_id = next_cycle.nil? ? DleCycle.all_by_stage.first.id : next_cycle.id
    self.user.user_dle_plans << new_stage 
  end

  def package
    UserDlePlan.find(:all, :conditions =>["user_id =? && plan = ?", self.user_id, self.plan])
  end

  def plan_with_targets
    self.package.select{|p| !p.user_dle_plan_metrics.empty?}.last rescue nil
  end
  def preferences(org)
    pref = org.dle_cycle_orgs.for_dle_cycle(self.dle_cycle).first rescue nil
    preference = pref.nil? ? self.dle_cycle : pref
  end

end
