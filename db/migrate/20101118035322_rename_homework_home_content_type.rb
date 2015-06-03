class RenameHomeworkHomeContentType < ActiveRecord::Migration
  def self.up
    rename_column :homeworks , :home_content_type , :homework_content_type 
  end

  def self.down
    rename_column :homeworks , :homework_content_type , :home_content_type
  end
end
