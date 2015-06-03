class CreateActBenchmarks < ActiveRecord::Migration
  def self.up
    create_table :act_benchmarks do |t|
      t.integer :act_subject_id
      t.integer :act_standard_id
      t.integer :act_score_range_id
      t.string  :benchmark_type
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :act_benchmarks
  end
end
