class CreateIstaSteps < ActiveRecord::Migration
  def self.up
    create_table :ista_steps do |t|
      t.integer :step_number
      t.string :name
      t.boolean :is_active
      t.string :background

      t.timestamps
    end
  end

  def self.down
    drop_table :ista_steps
  end
end
