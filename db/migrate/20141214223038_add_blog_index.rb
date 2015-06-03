class AddBlogIndex < ActiveRecord::Migration
  def self.up
    add_column  :bios, :job_title, :text, :limit => 1024
    add_index :bios, [:bioable_type, :bioable_id]
    remove_index :blogs, [:organization_id]
    remove_index :blogs, [:coop_app_id]
    remove_index :blogs, [:blog_type_id]
    add_index :blogs, [:organization_id, :blog_type_id, :coop_app_id], :name=>"org_type_app"
    add_index :blogs, [:organization_id, :coop_app_id, :blog_type_id], :name=>"org_app_type"
    add_index :blogs, [:coop_app_id, :organization_id], :name=>"app_org_type"
    add_index :blogs, [:blog_type_id, :organization_id], :name=>"type_org"
    add_index :blogs, [:blog_panel_id], :name=>"panel"
  end

  def self.down
    remove_index :blogs, [:blog_panel_id]
    remove_index :blogs, [:blog_type_id, :organization_id]
    remove_index :blogs, [:coop_app_id, :organization_id]
    remove_index :blogs, [:organization_id, :coop_app_id, :blog_type_id]
    remove_index :blogs, [:organization_id, :blog_type_id, :coop_app_id]
    add_index :blogs, [:blog_type_id]
    add_index :blogs, [:coop_app_id]
    add_index :blogs, [:organization_id]
    remove_index :bios, [:bioable_type, :bioable_id]
    remove_column  :bios, :job_title
  end
end
