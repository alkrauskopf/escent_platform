class CreateUserItlBeltRanks < ActiveRecord::Migration
  def self.up
    create_table :user_itl_belt_ranks do |t|
      t.integer :user_id
      t.integer :itl_belt_rank_id
      t.string :grantor_name, :limit=>40, :default=>""
      t.text :justification#, :default=>""

      t.timestamps
    end
  add_index :user_itl_belt_ranks, :itl_belt_rank_id
  add_index :user_itl_belt_ranks, :user_id
  
  end

  def self.down
    drop_table :user_itl_belt_ranks
  end
end
