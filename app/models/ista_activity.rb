class IstaActivity < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :ista_step
  belongs_to :ista_group

  has_many   :ista_case_allocations, :as => :activity, :dependent => :destroy
  
  scope :active, :conditions => ["is_active"], :order => 'seq_num'
  scope :for_step, lambda{|step| {:conditions => ["ista_step_id = ? ", step.id], :order => "seq_num ASC"}}

end
