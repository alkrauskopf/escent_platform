class AddTermsOfServiceToContents < ActiveRecord::Migration
  def self.up
    add_column :contents , :terms_of_service , :boolean , :default => nil
  end

  def self.down
    remove_column :contents , :terms_of_service
  end
end
