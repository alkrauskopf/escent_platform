class CreateCoopAppResourcesSubjects < ActiveRecord::Migration
  def self.up
    create_table :coop_app_resources_subjects do |t|
      t.integer :coop_app_id
      t.integer :subject_area_id

      t.timestamps
    end
    add_index :coop_app_resources_subjects, :coop_app_id
    add_index :coop_app_resources_subjects, :subject_area_id
  end

  def self.down
    drop_table :coop_app_resources_subjects
  end
end
