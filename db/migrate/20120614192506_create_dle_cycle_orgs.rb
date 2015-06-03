class CreateDleCycleOrgs < ActiveRecord::Migration
  def self.up
    create_table :dle_cycle_orgs do |t|
      t.integer :organization_id
      t.integer :dle_cycle_id
      t.integer :tlt_survey_id
      t.boolean :is_output
      t.string :output_label
      t.boolean :is_targets
      t.boolean :is_actual
      t.boolean :is_attachable
      t.string :attach_label

      t.timestamps
    end
  add_index :dle_cycle_orgs, :dle_cycle_id
  add_index :dle_cycle_orgs, :organization_id   
  add_index :dle_cycle_orgs, :tlt_survey_id
  end

  def self.down
    drop_table :dle_cycle_orgs
  end
end
