class AddProviderOnlyEltActivity < ActiveRecord::Migration
  def self.up
   add_column  :elt_types, :provider_only, :boolean, :default=> false
   execute "UPDATE elt_types SET provider_only = 0" 
  end

  def self.down
   remove_column  :elt_types, :provider_only
  end
end
