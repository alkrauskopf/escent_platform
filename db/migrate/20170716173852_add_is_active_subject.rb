class AddIsActiveSubject < ActiveRecord::Migration
  def up
    add_column :act_subjects, :is_active, :boolean, :default => true
  end

  def down
    remove_column :act_subjects, :is_active
  end
end
