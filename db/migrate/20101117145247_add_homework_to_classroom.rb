class AddHomeworkToClassroom < ActiveRecord::Migration
  def self.up
    add_column :classrooms, :homework_option, :boolean, :default => true
    execute "UPDATE classrooms SET homework_option = 1"
  end

  def self.down
    remove_column :classrooms, :homework_option
  end
end
