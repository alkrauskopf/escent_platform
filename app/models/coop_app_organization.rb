class CoopAppOrganization < ActiveRecord::Base

  belongs_to :coop_app
  belongs_to :organization
  belongs_to :app_provider, :class_name=> 'Organization', :foreign_key => "provider_id"
  
  scope :owner, :conditions => { :is_owner => true }
  scope :provider, :conditions => { :is_owner => true }
  scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id]}}
  scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}
  scope :selected, :conditions => { :is_selected => true }
  scope :allowed, :conditions => { :is_allowed => true }
  scope :enabled, {:conditions => ["is_selected AND is_allowed"]}
  scope :disallowed, :conditions => { :is_allowed => false }

end
