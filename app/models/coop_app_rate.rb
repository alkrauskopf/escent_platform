class CoopAppRate < ActiveRecord::Base

  belongs_to :coop_app
  belongs_to  :coop_group_code

  scope :for_group, lambda{|group| {:conditions => ["coop_group_code_id = ?", group_id]}}
  scope :default, :conditions => { :is_default => true }


end
