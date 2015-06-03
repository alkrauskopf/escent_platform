class RemoveOrganizationIdFromTopics < ActiveRecord::Migration
  def self.up
    remove_column :topics, :organization_id
  end

  def self.down
    add_column :topics, :organization_id, :integer
  end
end
