class CreateTltCycles < ActiveRecord::Migration
  def self.up
    create_table :tlt_cycles do |t|
      t.string :cycle
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :tlt_cycles
  end
end
