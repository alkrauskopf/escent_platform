class CreateEltElements < ActiveRecord::Migration
  def self.up
    create_table :elt_elements do |t|
      t.string :name, :limit => 50
      t.string :abbrev, :limit => 5
      t.integer :position
      t.boolean :is_active, :default => true
      t.text :description, :limit => 512

      t.timestamps
    end

    add_column :elt_elements, :form_background, :string, :limit => 7

  end

  def self.down
    drop_table :elt_elements
  end
end
