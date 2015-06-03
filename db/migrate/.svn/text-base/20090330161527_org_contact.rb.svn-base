class OrgContact < ActiveRecord::Migration
  def self.up
    add_column :organizations, :contact_email, :string
    add_column :organizations, :contact_phone, :string
  end

  def self.down
    remove_column :organizations, :contact_email
    remove_column :organizations, :contact_phone
  end
end
