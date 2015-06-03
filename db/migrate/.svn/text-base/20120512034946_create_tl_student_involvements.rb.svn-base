class CreateTlStudentInvolvements < ActiveRecord::Migration
  def self.up
    create_table :tl_student_involvements do |t|
      t.string :label, :limit => 10
      t.integer :score

      t.timestamps
    end
  end

  def self.down
    drop_table :tl_student_involvements
  end
end
