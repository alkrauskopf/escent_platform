class AddWasSelectedToActAnswers < ActiveRecord::Migration
  def self.up
    add_column :act_answers, :was_selected, :boolean
  end

  def self.down
    remove_column :act_answers, :was_selected
  end
end
