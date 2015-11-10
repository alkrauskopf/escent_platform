class CoopAppOrganization < ActiveRecord::Base

  belongs_to :coop_app
  belongs_to :organization
  belongs_to :app_provider, :class_name=> 'Organization', :foreign_key => "provider_id"
  
  named_scope :owner, :conditions => { :is_owner => true }
  named_scope :provider, :conditions => { :is_owner => true }
  named_scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id]}}
  named_scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}
  named_scope :selected, :conditions => { :is_selected => true }
  named_scope :allowed, :conditions => { :is_allowed => true }
  named_scope :enabled, {:conditions => ["is_selected AND is_allowed"]}
  named_scope :disallowed, :conditions => { :is_allowed => false }

end
