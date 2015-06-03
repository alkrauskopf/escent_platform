class CreateStatusInActQuestion < ActiveRecord::Migration
  def self.up
    add_column :act_questions, :status, :string
    add_column :act_choices, :answer, :string  
  end

  def self.down
    remoce_column :act_questions, :status
    remove_column :act_choices, :answer
  end
end
