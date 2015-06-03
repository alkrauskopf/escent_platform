class CreateOrganizationClients < ActiveRecord::Migration
  def self.up
    create_table :organization_clients do |t|
      t.integer :organization_id
      t.integer :client_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_clients
  end
end
