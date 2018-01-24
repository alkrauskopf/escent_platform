class AddIndexStrategyLog < ActiveRecord::Migration
  def up
    remove_index(:act_strategy_logs, :name=>'user_subject_period')
    remove_index( :act_strategy_logs, :name=>'org_subject_period')
    remove_index(:act_strategy_logs, :name=>'classroom_subject_period')

    add_index :act_strategy_logs, [:user_id, :act_strategy_id, :period_end], :name=>'user_strategy_period'
    add_index :act_strategy_logs, [:organization_id, :act_strategy_id, :period_end], :name=>'org_strategy_period'
    add_index :act_strategy_logs, [:classroom_id, :act_strategy_id, :period_end], :name=>'classroom_strategy_period'
  end

  def down
    add_index :act_strategy_logs, [:user_id, :act_subject_id, :period_end], :name=>'user_subject_period'
    add_index :act_strategy_logs, [:organization_id, :act_subject_id, :period_end], :name=>'org_subject_period'
    add_index :act_strategy_logs, [:classroom_id, :act_subject_id, :period_end], :name=>'classroom_subject_period'

    remove_index(:act_strategy_logs, :name=>'user_strategy_period')
    remove_index(:act_strategy_logs, :name=>'org_strategy_period')
    remove_index(:act_strategy_logs, :name=>'classroom_strategy_period')
  end
end
