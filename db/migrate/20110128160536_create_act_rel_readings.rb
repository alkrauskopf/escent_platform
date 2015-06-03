class CreateActRelReadings < ActiveRecord::Migration
  def self.up
    create_table :act_rel_readings do |t|
      t.integer :act_subject_id
      t.string :label
      t.string :target_score_range
      t.text :reading
      t.integer :user_id
      t.integer :organization_id

      t.timestamps
    end
  end

  def self.down
    drop_table :act_rel_readings
  end
end
