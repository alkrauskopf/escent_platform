class CreateTchrMetrics < ActiveRecord::Migration
  def self.up
    create_table :tchr_metrics do |t|
      t.string :name
      t.text :description
      t.boolean :for_teacher
      t.boolean :for_classroom

      t.timestamps
    end
  end

  def self.down
    drop_table :tchr_metrics
  end
end
