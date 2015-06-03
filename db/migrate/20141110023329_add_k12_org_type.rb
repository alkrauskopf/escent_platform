class AddK12OrgType < ActiveRecord::Migration
  def self.up
   add_column  :organization_types, :is_k12, :boolean
  end

  def self.down
   remove_column  :organization_types, :is_k12
  end
end
