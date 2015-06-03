class AddShareableRubricEltActivity < ActiveRecord::Migration
  def self.up
    drop_table :elt_activity_shares
    add_column  :elt_types, :rubric_id, :integer
    
    add_index :elt_types, :rubric_id
  end

  def self.down
    remove_column  :elt_types, :rubric_id
    create_table :elt_activity_shares do |t|
      t.integer :rubric_id
      t.integer :elt_type_id
      t.integer :elt_org_option_id
      
      t.timestamps
    end

  end
end
