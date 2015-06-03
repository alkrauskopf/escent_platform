class AddDisplayPositionToClassrooms < ActiveRecord::Migration
  def self.up
    add_column :classroom_contents, :display_position, :integer, :default => 0
    execute "UPDATE classroom_contents SET display_position = position"
  end

  def self.down
    remove_column :classrooms_contents, :display_position
  end
end
