class CreateActAssessmentStrands < ActiveRecord::Migration
  def change
    create_table :act_assessment_strands do |t|
      t.integer :act_assessment_id
      t.integer :act_standard_id

      t.timestamps
    end
    add_index :act_assessment_strands, [:act_assessment_id]
    add_index :act_assessment_strands, [:act_standard_id]
  end
end
