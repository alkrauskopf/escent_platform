class CreateBlogTypes < ActiveRecord::Migration
  def self.up
    create_table :blog_types do |t|
      t.integer :blog_id
      t.string :blog_type
      t.string :label
      t.string :description

      t.timestamps
    end
    add_index :blog_types, :blog_id
    add_index :blog_types, :blog_type    
   
    
  end

  def self.down
    drop_table :blog_types
  end
end
