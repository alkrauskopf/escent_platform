class RenameUserRoles < ActiveRecord::Migration
  def self.up
    rename_table :user_roles, :role_memberships
    rename_column :role_memberships, :start_date, :starts_at
    rename_column :role_memberships, :end_date, :ends_at
  end

  def self.down
    rename_column :role_memberships, :starts_at, :start_date
    rename_column :role_memberships, :ends_at, :end_date
    rename_table :role_memberships, :user_roles
  end
end
