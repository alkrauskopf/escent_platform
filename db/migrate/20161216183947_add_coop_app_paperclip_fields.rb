class AddCoopAppPaperclipFields < ActiveRecord::Migration
  def up
    add_column :coop_apps, :picture_file_name, :string
    add_column :coop_apps, :picture_content_type, :string
    add_column :coop_apps, :picture_file_size, :integer
    add_column :coop_apps, :picture_updated_at, :datetime
  end

  def down
    remove_column :coop_apps, :picture_file_name
    remove_column :coop_apps, :picture_content_type
    remove_column :coop_apps, :picture_file_size
    remove_column :coop_apps, :picture_updated_at
  end
end
