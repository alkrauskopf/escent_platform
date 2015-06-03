class CreateBlog < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.column :user_id , :integer
      t.column :organization_id , :integer
      t.column :title , :string 
      t.column :description , :text 
      t.column :active , :boolean , :default => false
      t.column :created_at , :datetime
      t.column :updated_at , :datetime
    end
  end

  def self.down
    drop_table :blogs
  end
end
