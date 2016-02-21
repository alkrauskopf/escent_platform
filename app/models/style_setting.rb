class StyleSetting < Setting
  
  scope :colors, :conditions => ["group_name = ?", "Colors"], :order => "position"
end
