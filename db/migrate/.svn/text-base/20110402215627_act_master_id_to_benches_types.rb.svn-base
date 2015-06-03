class ActMasterIdToBenchesTypes < ActiveRecord::Migration
  def self.up

  add_column :act_bench_types, :for_resource_panel, :boolean
  add_column :act_bench_types, :for_dash_board, :boolean
  add_column :act_bench_types, :for_list, :boolean
  add_column :act_bench_types, :for_static, :boolean
  
  add_column :act_benches, :act_bench_type_id, :integer
  
  end

  def self.down

  remove_column :act_bench_types, :for_resource_panel
  remove_column :act_bench_types, :for_dash_board
  remove_column :act_bench_types, :for_list
  remove_column :act_bench_types, :for_static
 
  remove_column :act_benches, :act_bench_type_id
  
  end
end
