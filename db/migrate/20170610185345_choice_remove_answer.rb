class ChoiceRemoveAnswer < ActiveRecord::Migration
  def up
    remove_column :act_choices, :answer
  end

  def down
    add_column :act_choices, :answer, :string
  end
end
