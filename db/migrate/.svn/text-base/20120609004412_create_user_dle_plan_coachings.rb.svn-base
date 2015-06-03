class CreateUserDlePlanCoachings < ActiveRecord::Migration
  def self.up
    create_table :user_dle_plan_coachings do |t|
      t.integer :user_dle_plan_id
      t.integer :user_id
      t.string :comment

      t.timestamps
     end
     add_index :user_dle_plan_coachings, :user_dle_plan_id
  end

  def self.down
    drop_table :user_dle_plan_coachings
  end
end
