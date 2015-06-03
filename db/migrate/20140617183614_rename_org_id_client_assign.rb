class RenameOrgIdClientAssign < ActiveRecord::Migration
  def self.up

   remove_index :client_assignments, [:organization_id]
   rename_column  :client_assignments, :organization_id, :organization_client_id
   add_index :client_assignments, [:organization_client_id]
  end

  def self.down
   remove_index :client_assignments, [:organization_client_id]
   rename_column  :client_assignments, :organization_client_id, :organization_id
   add_index :client_assignments, [:organization_id]
  end
end
