class AddFeaturedTopicIdToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :featured_topic_id, :integer
    add_column :organizations, :default_address_id, :integer
  end

  def self.down
    remove_column :organizations, :featured_topic_id
    remove_column :organizations, :default_address_id
  end
end
