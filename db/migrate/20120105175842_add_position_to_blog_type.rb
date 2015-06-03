class AddPositionToBlogType < ActiveRecord::Migration
  def self.up
    
   add_column :blog_types, :position, :integer

  end

  def self.down
    
   remove_column :blog_types, :position
   
  end
end
