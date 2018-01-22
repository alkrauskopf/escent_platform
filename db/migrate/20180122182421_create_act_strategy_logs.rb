class CreateActStrategyLogs < ActiveRecord::Migration
  def change
    create_table :act_strategy_logs do |t|
      t.integer :act_strategy_id
      t.integer :user_id
      t.integer :organization_id
      t.integer :classroom_id
      t.integer :act_assessment_id
      t.integer :act_submission_id
      t.integer :preferred, :default=>0
      t.integer :mis_matches, :default=>0
      t.integer :incorrects, :default=>0

      t.timestamps
    end
    add_index :act_strategy_logs, [:act_strategy_id, :user_id]
    add_index :act_strategy_logs, [:act_strategy_id, :organization_id]
    add_index :act_strategy_logs, [:act_strategy_id, :classroom_id]
    add_index :act_strategy_logs, [:user_id]
    add_index :act_strategy_logs, [:organization_id]
    add_index :act_strategy_logs, [:classroom_id]
    add_index :act_strategy_logs, [:act_submission_id]
    add_index :act_strategy_logs, [:act_assessment_id]
  end
end
