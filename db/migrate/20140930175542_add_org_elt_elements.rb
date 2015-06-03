class AddOrgEltElements < ActiveRecord::Migration
  def self.up

    add_column  :elt_elements, :organization_id, :integer   
    add_index :elt_elements, [:organization_id]
    execute "UPDATE elt_elements SET organization_id = 50"
  end

  def self.down
    remove_column  :elt_elements, :organization_id

  end
end
