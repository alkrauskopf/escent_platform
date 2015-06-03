class RenameActBenchmark < ActiveRecord::Migration
  def self.up
    rename_table :act_benchmarks, :act_bnchmarks
    execute "UPDATE act_bnchmarks SET benchmark_type = 'Benchmark'"
  end

  def self.down
    rename_table  :act_bnchmarks, :act_benchmarks
  end
end
