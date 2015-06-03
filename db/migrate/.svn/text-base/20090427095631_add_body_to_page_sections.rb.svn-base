class AddBodyToPageSections < ActiveRecord::Migration
  def self.up
    add_column :page_sections, :body, :text
    add_column :page_sections, :author_id, :integer
  end

  def self.down
    remove_column :page_sections, :body
    remove_column :page_sections, :author_id
  end
end
