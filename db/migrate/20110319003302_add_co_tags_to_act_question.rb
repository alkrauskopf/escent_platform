class AddCoTagsToActQuestion < ActiveRecord::Migration
  def self.up

    add_column :act_questions, :co_standard_id, :integer  
    add_column :act_questions, :co_grade_level_id, :integer  
  end

  def self.down

    remove_column :act_questions, :co_standard_id  
    remove_column :act_questions, :co_grade_level_id
  
  end
end
