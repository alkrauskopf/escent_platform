class CreateActQuestionReadings < ActiveRecord::Migration
  def self.up
    create_table :act_question_readings do |t|
      t.integer :act_question_id
      t.text :reading

      t.timestamps
    end
  end

  def self.down
    drop_table :act_question_readings
  end
end
