class AddUserIdToActBenchmark < ActiveRecord::Migration
  def self.up
    add_column :act_benchmarks, :user_id,:integer
    add_column :act_benchmarks, :organization_id,:integer  
  end

  def self.down
    remove_column :act_benchmarks, :user_id
    remove_column :act_benchmarks, :organization_id
  end
end
