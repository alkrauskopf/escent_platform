class AddViewablesToBenchmark < ActiveRecord::Migration
  def change
    add_column :act_benches, :is_s_viewable, :boolean, :default=>true
    add_column :act_benches, :is_q_taggable, :boolean, :default=>true
    execute "UPDATE act_benches SET is_active = 1"
  end
end
