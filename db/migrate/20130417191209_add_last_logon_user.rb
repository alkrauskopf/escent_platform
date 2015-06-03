class AddLastLogonUser < ActiveRecord::Migration
  def self.up

   add_column :users, :last_logon, :date

  end

  def self.down
   remove_column :users, :last_logon
  end
end
