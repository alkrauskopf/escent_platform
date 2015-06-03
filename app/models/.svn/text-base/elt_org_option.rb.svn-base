class EltOrgOption < ActiveRecord::Base

  include PublicPersona

  belongs_to :organization
  belongs_to :elt_provider, :class_name => 'Organization', :foreign_key => "owner_org_id"
  belongs_to :elt_cycle

end
