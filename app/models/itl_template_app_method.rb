class ItlTemplateAppMethod < ActiveRecord::Base

  belongs_to  :app_method
  belongs_to  :itl_template

  named_scope :for_app, lambda{|app| {:conditions => ["app_method_id = ? ", app.id]}}


end
