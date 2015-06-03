class CreateUserDlePlans < ActiveRecord::Migration
  def self.up
    create_table :user_dle_plans do |t|
      t.integer :user_id
      t.integer :dle_cycle_id
      t.date :date_finalized
      t.text :observations
      t.text :goals
      t.text :evaluation

      t.timestamps
    end
  add_index :user_dle_plans, [:user_id, :dle_cycle_id]
  add_index :user_dle_plans, :date_finalized
  end

  def self.down
    drop_table :user_dle_plans
  end
end
