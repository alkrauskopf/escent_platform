class CreateClientAssignments < ActiveRecord::Migration
  def self.up
    create_table :client_assignments do |t|
      t.integer :user_id
      t.integer :client_id

      t.timestamps
    end
    add_index :client_assignments, [:user_id]
    add_index :client_assignments, [:client_id]
    add_index :organization_clients, [:organization_id]
    add_index :organization_clients, [:client_id]
  end

  def self.down
    drop_table :client_assignments
  end
end
