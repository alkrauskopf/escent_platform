class RemoveUserOtherDenomination < ActiveRecord::Migration
  def self.up
    remove_column :users, :other_denomination
  end

  def self.down
    add_column :users, :other_denomination, :string
  end
end
