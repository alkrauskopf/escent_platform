class CreateCoGleEvidenceOutcomes < ActiveRecord::Migration
  def self.up
    create_table :co_gle_evidence_outcomes do |t|
      t.integer :co_gle_id
      t.string :description
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :co_gle_evidence_outcomes
  end
end
