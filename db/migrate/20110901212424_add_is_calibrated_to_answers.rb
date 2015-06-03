class AddIsCalibratedToAnswers < ActiveRecord::Migration
  def self.up
   add_column :act_answers, :is_calibrated, :boolean
   execute "UPDATE act_answers SET is_calibrated = 0"
  end

  def self.down
   remove_column :act_answers, :is_calibrated
  
  end
end
