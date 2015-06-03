class CreateEltCases < ActiveRecord::Migration
  def self.up
    create_table :elt_cases do |t|
      t.integer :organization_id
      t.integer :user_id
      t.integer :reviewer_id
      t.string :user_name
      t.string :reviewer_name
      t.date :submit_date
      t.boolean :is_submitted, :default => false
      t.date :finalize_date
      t.boolean :is_final, :default => false

      t.timestamps
    end

    add_index :elt_cases, [:organization_id]
    add_index :elt_cases, [:user_id]
    add_index :elt_cases, [:reviewer_id]

  end

  def self.down
    drop_table :elt_cases
  end
end
