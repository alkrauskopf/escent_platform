class AddIsActiveOrgClients < ActiveRecord::Migration
  def self.up

    add_column  :organization_clients, :is_active, :boolean, :default => 1

  end

  def self.down

    remove_column  :organization_clients, :is_active

  end
end
