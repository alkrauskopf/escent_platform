class AddIsCoreSubjectAreas < ActiveRecord::Migration
  def self.up
    add_column  :subject_areas, :is_core, :boolean
  end

  def self.down
    remove_column  :subject_areas, :is_core
  end
end
