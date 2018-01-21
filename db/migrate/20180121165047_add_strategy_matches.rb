class AddStrategyMatches < ActiveRecord::Migration
  def up
    add_column :act_assessments, :strategy_choices, :integer, :default=>0
    add_column :act_assessments, :strategy_matches, :integer, :default=>0
    add_column :act_submissions, :strategy_matches, :integer, :default=>0
  end

  def down
    remove_column :act_assessments, :strategy_choices
    remove_column :act_assessments, :strategy_matches
    remove_column :act_submissions, :strategy_matches
  end
end
