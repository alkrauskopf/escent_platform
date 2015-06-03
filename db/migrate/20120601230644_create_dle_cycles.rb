class CreateDleCycles < ActiveRecord::Migration
  def self.up
    create_table :dle_cycles do |t|
      t.integer :stage
      t.string :name
      t.text :description
      t.boolean :is_observation
      t.boolean :is_goals
      t.boolean :is_targets
      t.boolean :is_evaluation

      t.timestamps
    end
  end

  def self.down
    drop_table :dle_cycles
  end
end
