class RenameActSystemIdColumns < ActiveRecord::Migration
  def self.up

    rename_column :act_app_options, :act_system_id, :act_master_id
    rename_column :act_bench_types, :act_system_id, :act_master_id
    rename_column :act_benches, :act_system_id, :act_master_id
    rename_column :act_score_ranges, :act_system_id, :act_master_id
    rename_column :act_snapshots, :act_system_id, :act_master_id
    rename_column :act_standards, :act_system_id, :act_master_id
    add_column :users, :act_master_id, :integer
    
  end

  def self.down
  
    rename_column :act_app_options, :act_master_id, :act_system_id
    rename_column :act_bench_types, :act_master_id, :act_system_id
    rename_column :act_benches, :act_master_id, :act_system_id
    rename_column :act_score_ranges, :act_master_id, :act_system_id
    rename_column :act_snapshots, :act_master_id, :act_system_id
    rename_column :act_standards, :act_master_id, :act_system_id
    remove_column :users, :act_master_id
  
  end
end
