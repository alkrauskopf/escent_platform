class RenameOrganizationIdInOrganizationRelationships < ActiveRecord::Migration
  def self.up
    rename_column :organization_relationships, :organization_id, :source_id
    add_column    :organization_relationships, :source_type, :string, :limit => 32
    rename_column :organization_relationships, :scope_id, :target_id
    rename_column :organization_relationships, :scope_type, :target_type
    execute "UPDATE organization_relationships SET source_type = 'Organization'"
    execute "UPDATE organization_relationships SET relationship_type = 'content_partner' WHERE relationship_type = 'trusted_content_source'"
    execute "UPDATE organization_relationships SET relationship_type = 'discussion_partner' WHERE relationship_type = 'trusted_topic_source'"
  end

  def self.down
    rename_column :organization_relationships, :source_id, :organization_id
    remove_column :organization_relationships, :source_type
    rename_column :organization_relationships, :target_id, :scope_id
    rename_column :organization_relationships, :target_type, :scope_type
    execute "UPDATE organization_relationships SET relationship_type = 'trusted_topic_source' WHERE relationship_type = 'discussion_partner'"
    execute "UPDATE organization_relationships SET relationship_type = 'trusted_content_source' WHERE relationship_type = 'content_partner'"
  end
end
