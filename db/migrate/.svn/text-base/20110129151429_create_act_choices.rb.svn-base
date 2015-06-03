class CreateActChoices < ActiveRecord::Migration
  def self.up
    create_table :act_choices do |t|
      t.integer :act_question_id
      t.text :choice
      t.binary :correct
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :act_choices
  end
end
