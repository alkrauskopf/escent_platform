class AddBenchTypeAbbrev < ActiveRecord::Migration
  def up
    add_column :act_bench_types, :abbrev, :string
  end

  def down
    remove_column :act_bench_types, :abbrev
  end
end
