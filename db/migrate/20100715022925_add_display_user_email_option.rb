class AddDisplayUserEmailOption < ActiveRecord::Migration
  def self.up
    add_column :users, :display_emai_and_phone, :boolean, :default => true
    add_column :users, :website_referred_as, :string
  end

  def self.down
    remove_column :users, :display_emai_and_phone
    remove_column :users, :website_referred_as
  end
end
