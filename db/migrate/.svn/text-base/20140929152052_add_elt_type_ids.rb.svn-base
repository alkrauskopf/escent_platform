class AddEltTypeIds < ActiveRecord::Migration
  def self.up
    add_column  :elt_rubrics, :elt_type_id, :integer    
    add_index   :elt_rubrics, [:elt_type_id]
    
    add_column  :elt_indicators, :elt_type_id, :integer
    add_index   :elt_indicators, [:elt_type_id, :elt_element_id], :name=>"type_element"
    remove_index :elt_indicators, [:elt_element_id]
    add_index   :elt_indicators, [:elt_element_id, :elt_type_id], :name=>"element_type"

    add_column  :elt_cases, :elt_type_id, :integer
    remove_index :elt_cases, [:organization_id]
    add_index   :elt_cases, [:elt_type_id, :organization_id, :user_id], :name=>"element_type_org_user"
    add_index   :elt_cases, [:organization_id, :elt_type_id,:user_id], :name=>"element_org_type_user"
  end

  def self.down

    add_index :elt_cases, [:organization_id]
    remove_column  :elt_cases, :elt_type_id
    add_index :elt_indicators, [:elt_element_id]
    remove_column  :elt_indicators, :elt_type_id
    remove_column  :elt_rubrics, :elt_type_id

  end
end
