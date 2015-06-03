class DiscussionSetting < Setting
  named_scope :participation, :conditions => ["group_name = ?", "Participation"], :order => "position"
end
