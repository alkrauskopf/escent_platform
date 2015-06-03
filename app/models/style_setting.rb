class StyleSetting < Setting
  
  named_scope :colors, :conditions => ["group_name = ?", "Colors"], :order => "position"
end
