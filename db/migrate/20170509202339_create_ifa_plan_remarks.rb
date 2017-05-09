class CreateIfaPlanRemarks < ActiveRecord::Migration
  def change
    create_table :ifa_plan_remarks do |t|
      t.integer :ifa_plan_id
      t.integer :user_id
      t.string :teacher_name
      t.string :course_name
      t.text :remarks

      t.timestamps
    end
    add_index :ifa_plan_remarks, [:ifa_plan_id]
    add_index :ifa_plan_remarks, [:user_id, :ifa_plan_id ]
  end
end
