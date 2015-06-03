class AddAttachTitleToPlan < ActiveRecord::Migration
  def self.up
    add_column :user_dle_plans, :attach_content_type, :string
    add_column :user_dle_plans, :attach_title, :string
    add_column :user_dle_plans, :content_object_type_id, :integer
  end

  def self.down
    remove_column :user_dle_plans, :attach_content_type
    remove_column :user_dle_plans, :attach_title
    remove_column :user_dle_plans, :content_object_type_id
  end
end
