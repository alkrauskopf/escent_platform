class AddFrameworkColumnsIndices < ActiveRecord::Migration
  def self.up
    add_column :elt_cycles, :elt_framework_id, :integer
    add_column :elt_types, :elt_framework_id, :integer
    add_column :elt_elements, :elt_framework_id, :integer
    add_column :elt_org_options, :elt_framework_id, :integer

    add_index :elt_cycles, [:elt_framework_id]
    add_index :elt_types, [:elt_framework_id]
    add_index :elt_elements, [:elt_framework_id]
    add_index :elt_org_options, [:elt_framework_id]

    execute "UPDATE elt_cycles SET elt_framework_id = 1"
    execute "UPDATE elt_types SET elt_framework_id = 1"
    execute "UPDATE elt_elements SET elt_framework_id = 1"
  end

  def self.down
    remove_column :elt_cycles, :elt_framework_id, :integer
    remove_column :elt_types, :elt_framework_id, :integer
    remove_column :elt_elements, :elt_framework_id, :integer
    remove_column :elt_org_options, :elt_framework_id, :integer
  end
end
