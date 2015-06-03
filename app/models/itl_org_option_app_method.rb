class ItlOrgOptionAppMethod < ActiveRecord::Base

  belongs_to  :app_method
  belongs_to  :itl_org_option

  named_scope :for_app, lambda{|app| {:conditions => ["app_method_id = ? ", app.id]}}

end
