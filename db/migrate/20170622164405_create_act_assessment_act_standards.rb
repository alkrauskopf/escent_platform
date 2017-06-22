class CreateActAssessmentActStandards < ActiveRecord::Migration
  def change
    create_table :act_assessment_act_standards do |t|
      t.integer :act_assessment_id
      t.integer :act_standard_id

      t.timestamps
    end
    add_index :act_assessment_act_standards, [:act_assessment_id]
    add_index :act_assessment_act_standards, [:act_standard_id]
  end
end
