class ActBenchType < ActiveRecord::Base


  belongs_to :act_master

  has_many :act_benches, :dependent => :destroy

  scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  scope :for_resource_panel, :conditions => { :for_resource_panel => true }
  scope :for_dashboard, :conditions => { :for_dashbaord => true }
  scope :for_list, :conditions => { :for_list => true }
  scope :for_static, :conditions => { :for_statis => true }
  
end
