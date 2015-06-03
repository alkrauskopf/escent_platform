class AddStdView < ActiveRecord::Migration
  def self.up

    add_column :users, :std_view, :string
    execute "UPDATE users SET std_view = 'act'"  
  end

  def self.down

    remove_column :users, :std_view
  
  end
end
