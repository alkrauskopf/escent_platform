class AddSomeColumnsToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :instructional_remarks, :text
    add_column :topics, :assignments, :text
    add_column :topics, :estimated_start_date, :date
    add_column :topics, :estimated_end_date, :date
  end

  def self.down
    remove_column :topics, :instructional_remarks
    remove_column :topics, :assignments
    remove_column :topics, :estimated_start_date
    remove_column :topics, :estimated_end_date
  end
end
