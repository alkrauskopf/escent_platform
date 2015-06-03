class AddIsActiveToActQuestion < ActiveRecord::Migration
  def self.up
   add_column :act_questions, :is_active, :boolean
   execute "UPDATE act_questions SET is_active = 1"
  end

  def self.down
   remove_column :act_questions, :is_active
  
  end
end
