class CreateEltShareOptions < ActiveRecord::Migration
  def self.up
    create_table :elt_activity_shares do |t|
      t.integer :rubric_id
      t.integer :elt_type_id
      t.integer :elt_org_option_id
      
      t.timestamps
    end
   add_index :elt_activity_shares, [:elt_org_option_id, :elt_type_id], :name=>"org_activity_rubric"
   add_index :elt_activity_shares, [:elt_type_id, :elt_org_option_id], :name=>"activity_org"
   add_index :elt_activity_shares, [:rubric_id, :elt_org_option_id], :name=>"rubric_org"

  end

  def self.down
    drop_table :elt_activity_shares
  end
end
