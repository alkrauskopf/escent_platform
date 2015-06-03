class CreateRubrics < ActiveRecord::Migration
  def self.up
    create_table :rubrics do |t|
      t.integer :scope_id
      t.string :scope
      t.string :name, :limit => 15
      t.string :abbrev, :limit=>1  
      t.integer :score
      t.text :criteria

      t.timestamps
    end
  end

  def self.down
    drop_table :rubrics
  end
end
