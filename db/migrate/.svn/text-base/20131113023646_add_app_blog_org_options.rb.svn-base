class AddAppBlogOrgOptions < ActiveRecord::Migration
  def self.up

    add_column  :itl_org_options, :is_conversations, :boolean
    execute "UPDATE itl_org_options SET is_conversations = 1"
  end

  def self.down
    remove_column  :itl_org_options, :is_conversations
  end
end
