class AddNameEltCase < ActiveRecord::Migration
  def self.up

    add_column  :elt_cases, :name, :string
    add_column  :elt_cases, :object_name, :string
    add_column  :elt_cases, :classroom_id, :integer
    add_column  :elt_cases, :subject_area_id, :integer
    add_column  :elt_cases, :grade_level_id, :integer

    add_index :elt_cases, [:classroom_id]
    add_index :elt_cases, [:subject_area_id]
    add_index :elt_cases, [:grade_level_id]
  end

  def self.down
    remove_column  :elt_cases, :name
    remove_column  :elt_cases, :object_name
    remove_column  :elt_cases, :classroom_id
    remove_column  :elt_cases, :subject_area_id
    remove_column  :elt_cases, :grade_level_id
  end
end
