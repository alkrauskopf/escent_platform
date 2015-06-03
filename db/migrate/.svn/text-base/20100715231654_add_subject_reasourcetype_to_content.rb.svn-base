class AddSubjectReasourcetypeToContent < ActiveRecord::Migration
  def self.up
    add_column :contents, :subject_area, :string
    add_column :contents, :resource_type, :string
  end

  def self.down
    remove_column :contents, :resource_type
    remove_column :contents, :subject_area
  end
end
