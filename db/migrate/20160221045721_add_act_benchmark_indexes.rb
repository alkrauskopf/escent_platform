class AddActBenchmarkIndexes < ActiveRecord::Migration
  def self.up
    remove_index :act_benches, [:act_master_id]
    add_index :act_benches, [:act_master_id, :act_subject_id], :name=>'standard_subject'
    add_index :act_benches, [:act_master_id, :act_standard_id], :name=>'standard_strand'
  end

  def self.down
  end
end
