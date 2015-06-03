class CreateDleCoachAssignments < ActiveRecord::Migration
  def self.up
    create_table :dle_coach_assignments do |t|
      t.integer :coach_id
      t.integer :teacher_id

      t.timestamps
    end

  add_index :dle_coach_assignments, :coach_id
  add_index :dle_coach_assignments, :teacher_id
  end

  def self.down
    drop_table :dle_coach_assignments
  end
end
