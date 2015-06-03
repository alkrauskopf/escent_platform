class AddPositionToActBenchActQuestion < ActiveRecord::Migration
  def self.up
    add_column :act_bench_act_questions, :position, :integer
  end

  def self.down
    remove_column :act_bench_act_questions, :position
  end
end
