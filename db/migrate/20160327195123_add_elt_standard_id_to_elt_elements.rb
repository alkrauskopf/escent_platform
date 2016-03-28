class AddEltStandardIdToEltElements < ActiveRecord::Migration
  def self.up
    add_column :elt_elements, :elt_standard_id, :integer
    add_index :elt_elements, :elt_standard_id
  end

  def self.down
    remove_column :elt_elements, :elt_standard_id
  end
end
