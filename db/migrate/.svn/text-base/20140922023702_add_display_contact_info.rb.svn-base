class AddDisplayContactInfo < ActiveRecord::Migration
  def self.up
    add_column  :organizations, :display_contact, :boolean, :default => true

    execute "UPDATE organizations SET display_contact = 1"

  end

  def self.down
    remove_column  :organizations, :display_contact
  end
end
