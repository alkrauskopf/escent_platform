class CreateCoStandards < ActiveRecord::Migration
  def self.up
    create_table :co_standards do |t|
      t.integer :act_subject_id
      t.string :name
      t.integer :low_grade
      t.integer :high_grade
      t.string :grade_label

      t.timestamps
    end
  end

  def self.down
    drop_table :co_standards
  end
end
