class CreateOrganizationRelationships < ActiveRecord::Migration
  def self.up
    create_table :organization_relationships do |t|
      t.integer   :organization_id,                          :null => false
      t.string    :relationship_type,          :limit => 32, :null => false
      t.integer   :scope_id,                                 :null => false
      t.string    :scope_type,                 :limit => 32, :null => false
      t.boolean   :inclusive,                                :null => false, :default => true
      t.timestamps
    end
    
    add_index :organization_relationships, [:organization_id, :relationship_type], :name => "organization_id_and_relationship_type"
  end

  def self.down
    drop_table :organization_relationships
  end
end
