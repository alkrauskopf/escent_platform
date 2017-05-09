class RemoveIfaPlanTeacherRemarks < ActiveRecord::Migration
  def up
    drop_table :ifa_plan_teacher_remarks
  end

  def down
    create_table :ifa_plan_teacher_remarks do |t|
      t.integer :ifa_plan_id
      t.string :teacher_name
      t.string :course_name
      t.string :string
      t.text :remarks

      t.timestamps
    end
  end
end
