class AddSubmissionStratIndicator < ActiveRecord::Migration
  def up
    add_column :act_submissions, :is_strategy_test, :boolean, :default=>false
  end

  def down
    remove_column :act_submissions, :is_strategy_test
  end
end
