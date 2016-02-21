class SettingValue < ActiveRecord::Base
  belongs_to :scope, :polymorphic => true
  belongs_to :setting
  
  scope :style_settings, :include => :setting, :conditions => ["settings.type = ?", "StyleSetting"]
  scope :discussion_settings, :include => :setting, :conditions => ["settings.type = ?", "DiscussionSetting"]
  scope :search_settings, :include => :setting, :conditions => ["settings.type = ?", "SearchSetting"]
 
end
