class DiscussionSetting < Setting
  scope :participation, :conditions => ["group_name = ?", "Participation"], :order => "position"
end
