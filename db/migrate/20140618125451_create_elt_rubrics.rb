class CreateEltRubrics < ActiveRecord::Migration
  def self.up
    create_table :elt_rubrics do |t|
      t.string :name, :limit => 15
      t.integer :score
      t.string :criteria_condition, :limit => 512

      t.timestamps
    end
  end

  def self.down
    drop_table :elt_rubrics
  end
end
