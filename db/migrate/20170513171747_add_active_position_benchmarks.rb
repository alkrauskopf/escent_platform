class AddActivePositionBenchmarks < ActiveRecord::Migration
  def up
    add_column :act_benches, :is_active, :boolean, :default => false
    add_column :act_benches, :pos, :integer, :default => 0

    execute "UPDATE act_benches SET is_active = 1"
  end

  def down
    remove_column :act_benches, :is_active
    remove_column :act_benches, :pos
  end
end
