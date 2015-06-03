class SettingValue < ActiveRecord::Base
  belongs_to :scope, :polymorphic => true
  belongs_to :setting
  
  named_scope :style_settings, :include => :setting, :conditions => ["settings.type = ?", "StyleSetting"]
  named_scope :discussion_settings, :include => :setting, :conditions => ["settings.type = ?", "DiscussionSetting"]
  named_scope :search_settings, :include => :setting, :conditions => ["settings.type = ?", "SearchSetting"]
 
end
