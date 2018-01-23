class AddSubjectPeriodStrategyLog < ActiveRecord::Migration
  def up
    add_column :act_strategy_logs, :act_subject_id, :integer
    add_column :act_strategy_logs, :period_end, :date

    add_index :act_strategy_logs, [:act_subject_id, :user_id, :period_end], :name=>'subject_user_period'
    add_index :act_strategy_logs, [:act_subject_id, :organization_id, :period_end], :name=>'subject_org_period'
    add_index :act_strategy_logs, [:act_subject_id, :classroom_id, :period_end], :name=>'subject_classroom_period'
  end

  def down
    remove_column :act_strategy_logs, :act_subject_id
    remove_column :act_strategy_logs, :period_end
  end
end
