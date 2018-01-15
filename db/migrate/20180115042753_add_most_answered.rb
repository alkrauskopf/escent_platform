class AddMostAnswered < ActiveRecord::Migration
  def up
    add_column :act_assessments, :most_answered, :integer, :default=>0
  end

  def down
    remove_column :act_assessments, :most_answered
  end
end
