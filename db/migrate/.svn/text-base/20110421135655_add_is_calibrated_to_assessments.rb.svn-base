class AddIsCalibratedToAssessments < ActiveRecord::Migration
  def self.up

    rename_column :act_questions, :is_standard, :is_calibrated
    add_column :act_assessments, :is_calibrated, :boolean 
    execute "UPDATE act_assessments SET is_calibrated = 0"
  end

  def self.down
    rename_column :act_questions, :is_calibrated, :is_standard 
    remove_column :act_assessments, :is_calibrated    
  end
end
