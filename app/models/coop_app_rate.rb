class CoopAppRate < ActiveRecord::Base

  belongs_to :coop_app
  belongs_to  :coop_group_code

  named_scope :for_group, lambda{|group| {:conditions => ["coop_group_code_id = ?", group_id]}}
  named_scope :default, :conditions => { :is_default => true }


end
