class RemoveOrgRegisterNotfify < ActiveRecord::Migration
  def self.up
       remove_column  :organizations, :register_notify
  end

  def self.down
       add_column  :organizations, :register_notify, :boolean
  end
end
