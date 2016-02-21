class AppDiscussion < ActiveRecord::Base


  belongs_to  :coop_app
  belongs_to  :organization

  scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id]}}
  scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}

end
