class CreateContentResourceTypes < ActiveRecord::Migration
  def self.up
    create_table :content_resource_types, :force => true do |t|
      t.string :name, :limit => 50,  :null => false
      t.string :description, :limit => 150,  :null => false
      t.datetime :created_at, :null => false

    end
  end

  def self.down
    drop_table :content_resource_types
  end
end
