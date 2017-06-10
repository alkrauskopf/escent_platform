class ChoiceIsActive < ActiveRecord::Migration
  def up
    add_column :act_choices, :is_active, :boolean, :default => true
  end

  def down
    remove_column :act_choices, :is_active
  end
end
