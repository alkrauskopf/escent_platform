class CreateActBenches < ActiveRecord::Migration
  def self.up
    create_table :act_benches do |t|
      t.integer :act_subject_id
      t.integer :act_standard_id
      t.integer :act_score_range_id
      t.string :benchmark_type
      t.text :description
      t.integer :user_id
      t.integer :organization_id

      t.timestamps
    end
    execute "UPDATE act_benches SET benchmark_type ='benchmark'"
    execute "UPDATE act_benches SET description ='-none-'"  
  end

  def self.down
    drop_table :act_benches
  end
end
