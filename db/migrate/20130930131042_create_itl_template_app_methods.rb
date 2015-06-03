class CreateItlTemplateAppMethods < ActiveRecord::Migration
  def self.up
    create_table :itl_template_app_methods do |t|
      t.integer :itl_template_id
      t.integer :app_method_id

      t.timestamps
    end
    add_index :itl_template_app_methods, :itl_template_id
    add_index :itl_template_app_methods, [:app_method_id, :itl_template_id], :name => "app_method_template"

  end

  def self.down
    drop_table :itl_template_app_methods
  end
end
