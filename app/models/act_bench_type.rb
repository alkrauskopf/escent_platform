class ActBenchType < ActiveRecord::Base


  belongs_to :act_master

  has_many :act_benches, :dependent => :destroy

  named_scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  named_scope :for_resource_panel, :conditions => { :for_resource_panel => true }
  named_scope :for_dashboard, :conditions => { :for_dashbaord => true }
  named_scope :for_list, :conditions => { :for_list => true }
  named_scope :for_static, :conditions => { :for_statis => true }  
  
end
