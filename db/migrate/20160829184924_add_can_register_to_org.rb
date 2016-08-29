class AddCanRegisterToOrg < ActiveRecord::Migration
  def change
    add_column :organizations, :can_register, :boolean, :default => false
  end
end
