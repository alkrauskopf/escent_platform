class CreateCoSubjectsGls < ActiveRecord::Migration
  def self.up
    create_table :co_subjects_gls do |t|
      t.integer :act_subject_id
      t.string :level
      t.integer :lower_grade
      t.integer :upper_grade

      t.timestamps
    end
  end

  def self.down
    drop_table :co_subjects_gls
  end
end
