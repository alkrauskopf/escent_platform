class RenameDiscussionDeleteId < ActiveRecord::Migration
  def self.up

  rename_column :discussions, :deleted_by, :delete_user
  end

  def self.down

  rename_column :discussions, :delete_user, :deleted_by
  
  end
end
