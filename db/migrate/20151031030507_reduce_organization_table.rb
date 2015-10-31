class ReduceOrganizationTable < ActiveRecord::Migration
  def self.up
    remove_column  :organizations, :channel_id
    remove_column  :organizations, :religious_affiliation_id
    remove_column  :organizations, :iwing_tab_id
    remove_column  :organizations, :package_id
    remove_column  :organizations, :email_address
    remove_column  :organizations, :cause_streaming_source_id
  end

  def self.down
    add_column  :organizations, :channel_id, :integer
    add_column  :organizations, :religious_affiliation_id, :integer
    add_column  :organizations, :iwing_tab_id, :integer
    add_column  :organizations, :package_id, :integer
    add_column  :organizations, :email_address, :string
    add_column  :organizations, :cause_streaming_source_id, :integer
  end
end
