class AddIfaOnClassroom < ActiveRecord::Migration
  def up
    add_column :classrooms, :is_ifa, :boolean, :default => false
    execute "UPDATE classrooms SET is_ifa = is_prep"
  end

  def down
    remove_column :classrooms, :is_ifa
  end
end
