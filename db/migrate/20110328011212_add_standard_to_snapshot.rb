class AddStandardToSnapshot < ActiveRecord::Migration
  def self.up

    add_column :act_snapshots, :standard, :string
    execute "UPDATE act_snapshots SET standard = 'act'"  
  
  end

  def self.down

    remove_column :act_snapshots, :standard  
  
  end
end
