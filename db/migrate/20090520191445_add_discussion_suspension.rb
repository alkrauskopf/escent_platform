class AddDiscussionSuspension < ActiveRecord::Migration
  def self.up
    add_column :discussions, :suspended_at, :datetime
    add_column :discussions, :suspended_by, :integer        
  end

  def self.down
    remove_column :discussions, :suspended_at
    remove_column :discussions, :suspended_by
  end
end
