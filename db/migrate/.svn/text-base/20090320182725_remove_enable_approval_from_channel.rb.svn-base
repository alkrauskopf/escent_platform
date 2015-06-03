class RemoveEnableApprovalFromChannel < ActiveRecord::Migration
  def self.up
    remove_column :channels, :enable_approval
    change_column :channels, :publish_start_date, :datetime, :null => true
  end

  def self.down
    add_column :channels, :enable_approval, :boolean, :default => false
    change_column :channels, :publish_start_date, :datetime, :null => false
  end
end
