class CreateGradeLevels < ActiveRecord::Migration
  def self.up
    create_table :grade_levels do |t|
      t.integer :organization_type_id
      t.string :name
      t.integer :level
      t.string :abbrev

      t.timestamps
    end
  add_index :grade_levels, [:organization_type_id]
  end

  def self.down
    drop_table :grade_levels
  end
end
