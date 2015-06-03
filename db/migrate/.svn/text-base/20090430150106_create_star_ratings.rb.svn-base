class CreateStarRatings < ActiveRecord::Migration
  def self.up
    create_table :star_ratings do |t|
      t.integer :entity_id
      t.string  :entity_type, :limit => 32
      t.integer :votes, :default => 0
      t.decimal :rating, :precision => 5, :scale => 2, :default => 0.0
      t.timestamps
    end
  end

  def self.down
    drop_table :star_ratings
  end
end
