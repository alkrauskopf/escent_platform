class AddSubmissionsDurationDelta < ActiveRecord::Migration
  def up
    add_column :act_submissions, :duration_delta, :integer, :default=>0
  end

  def down
    remove_column :act_submissions, :duration_delta
  end
end
