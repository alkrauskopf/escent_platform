class CreateCoCsapRanges < ActiveRecord::Migration
  def self.up
    create_table :co_csap_ranges do |t|
      t.integer :act_subject_id
      t.string :range
      t.integer :lower_score
      t.integer :upper_score

      t.timestamps
    end
  add_index :co_csap_ranges, :act_subject_id
  
  end

  def self.down
    drop_table :co_csap_ranges
  end
end
