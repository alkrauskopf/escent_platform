class CreateActQuestionActStandards < ActiveRecord::Migration
  def self.up
    create_table :act_question_act_standards do |t|
      t.integer :act_question_id
      t.integer :act_standard_id

      t.timestamps
    end
    
  end

  def self.down
    drop_table :act_question_act_standards
    
  end
end
