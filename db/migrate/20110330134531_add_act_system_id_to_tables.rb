class AddActSystemIdToTables < ActiveRecord::Migration
  def self.up

    add_column :act_app_options, :act_system_id, :integer
    add_column :act_bench_types, :act_system_id, :integer
    add_column :act_benches, :act_system_id, :integer
    add_column :act_score_ranges, :act_system_id, :integer
    add_column :act_snapshots, :act_system_id, :integer
    add_column :act_standards, :act_system_id, :integer
  end

  def self.down

    remove_column :act_app_options, :act_system_id
    remove_column :act_bench_types, :act_system_id
    remove_column :act_benches, :act_system_id
    remove_column :act_score_ranges, :act_system_id
    remove_column :act_snapshots, :act_system_id
    remove_column :act_standards, :act_system_id
  
  end
end
