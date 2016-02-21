class CreateItlSummaries < ActiveRecord::Migration
  def self.up
    create_table :itl_summaries do |t|
      t.integer :organization_id
      t.integer :user_id
      t.integer :subject_area_id
      t.integer :organization_type_id
      t.integer :year_month
      t.integer :observation_count
      t.integer :classroom_duration
      t.integer :observation_duration

      t.timestamps
    end

    add_index :itl_summaries, [:organization_id, :year_month, :subject_area_id], :name => "org_period_subject"

  end

  def self.down
    drop_table :itl_summaries
  end
end
