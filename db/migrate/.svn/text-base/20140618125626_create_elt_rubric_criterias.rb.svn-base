class CreateEltRubricCriterias < ActiveRecord::Migration
  def self.up
    create_table :elt_rubric_criterias do |t|
      t.integer :elt_rubric_id
      t.integer :position
      t.string :description, :limit => 512

      t.timestamps
    end

    add_index :elt_rubric_criterias, [:elt_rubric_id]

  end

  def self.down
    drop_table :elt_rubric_criterias
  end
end
