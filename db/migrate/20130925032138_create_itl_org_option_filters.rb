class CreateItlOrgOptionFilters < ActiveRecord::Migration
  def self.up
    create_table :itl_org_option_filters do |t|
      t.integer :itl_org_option_id
      t.integer :tl_activity_type_task_id

      t.timestamps
    end
    add_index :itl_org_option_filters, :itl_org_option_id
    add_index :itl_org_option_filters, [:tl_activity_type_task_id, :itl_org_option_id], :name => "filter_org_option"

  end

  def self.down
    drop_table :itl_org_option_filters
  end
end
