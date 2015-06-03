class CreateActBenchTypes < ActiveRecord::Migration
  def self.up
    create_table :act_bench_types do |t|
      t.string :name
      t.string :standard

      t.timestamps
    end
  end

  def self.down
    drop_table :act_bench_types
  end
end
