class AddOpenClassroom < ActiveRecord::Migration
  def self.up
    add_column  :classrooms, :is_open, :boolean
    add_column  :classrooms, :registration_key, :string, :limit => 8
    execute "UPDATE classrooms SET is_open = 1"
  end

  def self.down
    remove_column  :classrooms, :registration_key
    remove_column  :classrooms, :is_open
  end
end
