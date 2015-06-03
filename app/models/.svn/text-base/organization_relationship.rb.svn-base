class OrganizationRelationship < ActiveRecord::Base
  belongs_to :source, :polymorphic => true
  belongs_to :target, :polymorphic => true
  
  RelationshipTypes = ['content_partner', 'discussin_partner', 'allowed_content_audience']
  
end
