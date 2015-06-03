class AddReviewerIdToSubmissions < ActiveRecord::Migration
  def self.up
    add_column :act_submissions, :reviewer_id, :integer
  end

  def self.down
    remove_column :act_submissions, :reviewer_id
  end
end
