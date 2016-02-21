class SearchSetting < Setting
  
  scope :content, :conditions => ["group_name = ?", "Content"], :order => "position"
  
  ContentOptions = ["None", "Content Partners Only"]
end
