class AddCorrectCountStrategyLog < ActiveRecord::Migration
  def up
    add_column :act_strategy_logs, :corrects, :integer, :default=>0
    add_column :act_strategy_logs, :matches, :integer, :default=>0
  end

  def down
    remove_column :act_strategy_logs, :corrects
    remove_column :act_strategy_logs, :matches
  end
end
