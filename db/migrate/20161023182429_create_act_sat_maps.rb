class CreateActSatMaps < ActiveRecord::Migration
  def change
    create_table :act_sat_maps do |t|
      t.string :range
      t.integer :lower_score
      t.integer :upper_score

      t.timestamps
    end
  end
end
