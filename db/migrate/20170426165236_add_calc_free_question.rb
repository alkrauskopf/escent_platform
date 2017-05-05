class AddCalcFreeQuestion < ActiveRecord::Migration
  def up
    add_column :act_questions, :is_calc_free, :boolean, :default => false
    add_column :act_questions, :category, :integer, :default => 0
  end

  def down
    remove_column :act_questions, :is_calc_free
    remove_column :act_questions, :category
  end
end
