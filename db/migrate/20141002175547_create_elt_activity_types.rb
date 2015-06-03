class CreateEltActivityTypes < ActiveRecord::Migration
  def self.up
    create_table :elt_activity_types do |t|
      t.string :name
      t.string :description
      t.boolean :is_active

      t.timestamps
    end
      remove_column  :elt_types, :abbrev
      remove_column  :elt_types, :activity
      add_column  :elt_types,  :elt_activity_type_id, :integer
  end

  def self.down
     remove_column  :elt_types, :elt_activity_type_id
     add_column  :elt_types,  :activity, :string
     add_column  :elt_types,  :abbrev, :string
    drop_table :elt_activity_types
  end
end
