class CreateEltTypes < ActiveRecord::Migration
  def self.up
    create_table :elt_types do |t|
      t.integer :organization_id
      t.string :abbrev,  :limit => 3
      t.string :type,  :limit => 15
      t.string :name
      t.boolean :is_active

      t.timestamps
    end
    add_index   :elt_types, [:organization_id, :type], :name=>"type_organization"
  end

  def self.down
    drop_table :elt_types
  end
end
