class AddGuardianCounters < ActiveRecord::Migration
  def up
    add_column :user_guardians, :notify_count, :integer, :default => 0
    add_column :user_guardians, :inquiry_count, :integer, :default => 0
  end

  def down
    remove_column :user_guardians, :notify_count
    remove_column :user_guardians, :inquiry_count
  end
end
