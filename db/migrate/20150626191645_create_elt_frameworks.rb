class CreateEltFrameworks < ActiveRecord::Migration
  def self.up
    create_table :elt_frameworks do |t|
      t.integer :organization_id
      t.string :abbrev, :limit => 8
      t.string :name, :limit => 64

      t.timestamps
    end
    add_index :elt_frameworks, [:organization_id]
  end

  def self.down
    drop_table :elt_frameworks
  end
end
