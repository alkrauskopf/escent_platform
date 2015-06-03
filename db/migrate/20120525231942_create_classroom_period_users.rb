class CreateClassroomPeriodUsers < ActiveRecord::Migration
  def self.up
    create_table :classroom_period_users do |t|
      t.integer :classroom_period_id
      t.integer :user_id
      t.boolean :is_leader
      t.boolean :is_student

      t.timestamps
    end

    add_index :classroom_period_users, [:classroom_period_id, :user_id]
    add_index :classroom_period_users, [:user_id, :classroom_period_id]
  end

  def self.down
    drop_table :classroom_period_users
  end
end
