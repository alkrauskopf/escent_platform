class CreateItlTemplateFilters < ActiveRecord::Migration
  def self.up
    create_table :itl_template_filters do |t|
      t.integer :itl_template_id
      t.integer :tl_activity_type_task_id

      t.timestamps
    end
    add_index :itl_template_filters, :itl_template_id
    add_index :itl_template_filters, [:tl_activity_type_task_id, :itl_template_id], :name => "task_template"

  end

  def self.down
    drop_table :itl_template_filters
  end
end
