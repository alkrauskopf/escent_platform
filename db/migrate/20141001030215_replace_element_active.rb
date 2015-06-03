class ReplaceElementActive < ActiveRecord::Migration
  def self.up
    remove_column  :elt_elements, :is_active
    add_column  :elt_elements, :is_active, :boolean
    execute "UPDATE elt_elements SET is_active = 1" 
  end

  def self.down
    remove_column  :elt_elements, :is_active
    add_column  :elt_elements, :is_active, :boolean
  end
end
