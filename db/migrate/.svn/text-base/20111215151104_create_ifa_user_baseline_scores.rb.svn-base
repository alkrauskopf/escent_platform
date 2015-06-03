class CreateIfaUserBaselineScores < ActiveRecord::Migration
  def self.up
    create_table :ifa_user_baseline_scores do |t|
      t.integer :user_id
      t.integer :act_master_id
      t.integer :score

      t.timestamps
    end
    add_index :ifa_user_baseline_scores, :user_id
    add_index :ifa_user_baseline_scores, :act_master_id

  end

  def self.down
    drop_table :ifa_user_baseline_scores
  end
end
