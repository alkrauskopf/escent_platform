class RemovePasswordConstraint < ActiveRecord::Migration
  def self.up
    change_column :users, :password, :string, :null => true
  end

  def self.down
    change_column :users, :password, :string, :null => false
  end
end
