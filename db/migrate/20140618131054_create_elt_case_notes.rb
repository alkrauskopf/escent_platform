class CreateEltCaseNotes < ActiveRecord::Migration
  def self.up
    create_table :elt_case_notes do |t|
      t.integer :elt_case_id
      t.integer :elt_element_id
      t.string :user_name
      t.text :note, :limit => 1024

      t.timestamps
    end

    add_index :elt_case_notes, [:elt_case_id]
    add_index :elt_case_notes, [:elt_element_id]

  end

  def self.down
    drop_table :elt_case_notes
  end
end
