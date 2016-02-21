class OrganizationClient < ActiveRecord::Base

  belongs_to :organization 
  
  belongs_to :client, :class_name => 'Organization', :foreign_key => "client_id"

  has_many :client_assignments, :dependent => :destroy
  has_many :consultants, :through => :client_assignments, :order => "last_name"

  scope :for_client, lambda{|client| {:conditions => ["client_id = ? ", client.id]}}
  scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}

  scope :active, {:conditions =>["is_active = ?", true]}


end
