class AddIsActiveToActAssessment < ActiveRecord::Migration
  def self.up

   add_column :act_assessments, :is_active, :boolean
   execute "UPDATE act_assessments SET is_active = 1"
  
  end

  def self.down

   remove_column :act_assessments, :is_active
  
  end
end
