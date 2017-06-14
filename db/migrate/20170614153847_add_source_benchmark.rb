class AddSourceBenchmark < ActiveRecord::Migration
  def up
    add_column :act_benches, :source_level_id, :integer
    add_column :act_benches, :source_strand_id, :integer
    add_index :act_benches, [:source_level_id, :source_strand_id]
    add_index :act_benches, [:source_strand_id, :source_level_id]
  end

  def down
    remove_column :act_benches, :source_level_id
    remove_column :act_benches, :source_strand_id
  end
end
