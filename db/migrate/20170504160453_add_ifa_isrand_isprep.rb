class AddIfaIsrandIsprep < ActiveRecord::Migration
  def up
    add_column :act_questions, :is_random, :boolean, :default => true
    add_column :classrooms, :is_prep, :boolean, :default => false
  end

  def down
    remove_column :act_questions, :is_random
    remove_column :classrooms, :is_prep
  end
end
