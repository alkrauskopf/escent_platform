class AddPictureMagnifyToQuestion < ActiveRecord::Migration
  def self.up
   add_column :act_questions, :is_enlarged, :boolean
   execute "UPDATE act_questions SET is_enlarged = 0"
  end

  def self.down
   remove_column :act_questions, :is_enlarged
  end
end
