class AddFixStrategyLogIndex < ActiveRecord::Migration
  def change
    drop_table :act_strategy_logs
    create_table :act_strategy_logs do |t|
      t.integer :act_strategy_id
      t.integer :user_id
      t.integer :organization_id
      t.integer :classroom_id
      t.integer :act_assessment_id
      t.integer :act_submission_id
      t.integer :act_subject_id
      t.integer :preferred, :default=>0
      t.integer :mis_matches, :default=>0
      t.integer :incorrects, :default=>0
      t.date    :period_end

      t.timestamps
    end
    add_index :act_strategy_logs, [:act_submission_id]
    add_index :act_strategy_logs, [:act_assessment_id]
    add_index :act_strategy_logs, [:user_id, :act_subject_id, :period_end], :name=>'user_subject_period'
    add_index :act_strategy_logs, [:organization_id, :act_subject_id, :period_end], :name=>'org_subject_period'
    add_index :act_strategy_logs, [:classroom_id, :act_subject_id, :period_end], :name=>'classroom_subject_period'
    add_index :act_strategy_logs, [:act_subject_id, :period_end], :name=>'subject_period'
    add_index :act_strategy_logs, [:act_strategy_id, :period_end], :name=>'strategy_period'
  end
end
