class CreateItlOrgOptionAppMethods < ActiveRecord::Migration
  def self.up
    create_table :itl_org_option_app_methods do |t|
      t.integer :itl_org_option_id
      t.integer :app_method_id

      t.timestamps
    end
    add_index :itl_org_option_app_methods, :itl_org_option_id
    add_index :itl_org_option_app_methods, [:app_method_id, :itl_org_option_id], :name => "app_method_org_option"

  end

  def self.down
    drop_table :itl_org_option_app_methods
  end
end
