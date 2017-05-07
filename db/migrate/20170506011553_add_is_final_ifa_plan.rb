class AddIsFinalIfaPlan < ActiveRecord::Migration
  def up
    add_column :ifa_plans, :is_final, :boolean, :default => false
    remove_column :ifa_plans, :act_master_id
  end

  def down
    remove_column :ifa_plans, :is_final
    add_column :ifa_plans, :act_master_id, :integer
    add_index :ifa_plans, [:act_master_id, :act_subject_id, :user_id]
    add_index :ifa_plans, [:act_subject_id, :user_id]
  end
end
