class AddCauseStreammingSourceIdToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :cause_streaming_source_id, :integer, :default => 1
  end

  def self.down
    remove_column :organizations, :cause_streaming_source_id
  end
end
