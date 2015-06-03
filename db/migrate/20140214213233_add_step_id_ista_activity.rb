class AddStepIdIstaActivity < ActiveRecord::Migration
  def self.up
    add_column  :ista_activities, :ista_step_id, :integer
    remove_column  :ista_activities, :type
    remove_column  :ista_activities, :type_name
    remove_column  :ista_activities, :abbrev
    add_index :ista_activities, :ista_step_id

  end

  def self.down
    add_column  :ista_activities, :type, :string
    add_column  :ista_activities, :type_name, :string
    add_column  :ista_activities, :abbrev, :string
    remove_column  :ista_activities, :ista_step_id
  end
end
