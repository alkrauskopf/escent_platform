class CreatePageSections < ActiveRecord::Migration
  def self.up
    create_table :page_sections do |t|
      t.integer  :organization_id,  :null => false
      t.string   :page,             :null => false
      t.string   :section
      t.integer  :content_id
      t.timestamps
    end
    add_index :page_sections, [:organization_id, :page, :section]
  end

  def self.down
    drop_table :page_sections
  end
end
