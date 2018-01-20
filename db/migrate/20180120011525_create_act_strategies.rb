class CreateActStrategies < ActiveRecord::Migration
  def change
    create_table :act_strategies do |t|
      t.integer :act_subject_id
      t.integer :pos, :default=>0
      t.string :name
      t.text :description
      t.boolean :is_active, :default=>true

      t.timestamps
    end
    add_column :act_assessments, :is_strategy_test, :boolean, :default=>false
    add_column :act_questions, :act_strategy_id, :integer
    add_column :act_answers, :act_strategy_id, :integer

    add_index :act_strategies, [:act_subject_id]
    add_index :act_questions, [:act_strategy_id]
    add_index :act_answers, [:act_strategy_id]
  end
end
