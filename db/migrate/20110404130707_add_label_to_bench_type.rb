class AddLabelToBenchType < ActiveRecord::Migration
  def self.up

  add_column :act_bench_types, :long_name, :string
  add_column :act_bench_types, :description, :text  
  
  end

  def self.down

  remove_column :act_bench_types, :long_name
  remove_column :act_bench_types, :description 
 
  end
end
