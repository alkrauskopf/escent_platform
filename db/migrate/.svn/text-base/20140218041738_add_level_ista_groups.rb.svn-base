class AddLevelIstaGroups < ActiveRecord::Migration
  def self.up
    rename_column  :ista_groups, :subject_list_name, :level_name
    remove_column  :ista_groups, :support_name
    add_column  :ista_groups, :group_code, :string, :limit=>1
    add_column  :ista_groups, :level, :integer
    add_column  :subject_areas, :is_academic, :boolean
  end

  def self.down
    remove_column  :subject_areas, :is_academic
    remove_column  :ista_groups, :level
    remove_column  :ista_groups, :group_code
    add_column  :ista_groups, :support_name, :string
    rename_column  :ista_groups, :level_name, :subject_list_name

  end
end
