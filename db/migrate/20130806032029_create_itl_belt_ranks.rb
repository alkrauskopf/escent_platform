class CreateItlBeltRanks < ActiveRecord::Migration
  def self.up
    create_table :itl_belt_ranks do |t|
      t.string :rank
      t.integer :rank_score
      t.string :image
      t.text :criteria

      t.timestamps
    end
  end

  def self.down
    drop_table :itl_belt_ranks
  end
end
