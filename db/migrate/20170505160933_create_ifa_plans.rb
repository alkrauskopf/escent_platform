class CreateIfaPlans < ActiveRecord::Migration
  def change
    create_table :ifa_plans do |t|
      t.integer :user_id
      t.integer :act_subject_id
      t.integer :act_master_id
      t.string :current_mastery
      t.text :needs
      t.text :goals
      t.date :goal_date
      t.boolean :is_accepted, :default=> false
      t.string :accepted_by
      t.date :accepted_date

      t.timestamps
    end
    add_index :ifa_plans, [:user_id]
    add_index :ifa_plans, [:act_master_id, :act_subject_id, :user_id]
    add_index :ifa_plans, [:act_subject_id, :user_id]
  end
end
