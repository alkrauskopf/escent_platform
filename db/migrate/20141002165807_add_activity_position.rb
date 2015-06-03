class AddActivityPosition < ActiveRecord::Migration
  def self.up

    add_column  :elt_types, :position, :integer, :default=>1
    add_column  :elt_types, :use_rubric, :boolean, :default=>false
    execute "UPDATE elt_rubrics SET elt_type_id = 101" 
  end

  def self.down
    remove_column  :elt_types, :position
    remove_column  :elt_types, :use_rubric
  end
end
