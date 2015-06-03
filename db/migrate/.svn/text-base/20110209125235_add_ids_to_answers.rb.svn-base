class AddIdsToAnswers < ActiveRecord::Migration
  def self.up
    add_column :act_answers, :user_id, :integer
    add_column :act_answers, :organization_id, :integer
    add_column :act_answers, :classroom_id, :integer
    add_column :act_answers, :teacher_id, :integer
  end

  def self.down
    remove_column :act_answers, :user_id
    remove_column :act_answers, :organization_id
    remove_column :act_answers, :classroom_id
    remove_column :act_answers, :teacher_id
  end
end
