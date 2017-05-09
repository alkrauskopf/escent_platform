class CreateIfaPlanTeacherRemarks < ActiveRecord::Migration
  def change
    create_table :ifa_plan_teacher_remarks do |t|
      t.integer :ifa_plan_id
      t.string :teacher_name
      t.string :course_name
      t.string :string
      t.text :remarks

      t.timestamps
    end
    add_index :ifa_plan_teacher_remarks, [:ifa_plan_id]
  end
end
