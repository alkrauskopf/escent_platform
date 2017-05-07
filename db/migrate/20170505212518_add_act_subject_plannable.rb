class AddActSubjectPlannable < ActiveRecord::Migration
  def up
    add_column :act_subjects, :is_plannable, :boolean, :default => true
  end

  def down
    remove_column :act_subjects, :is_plannable
  end
end
