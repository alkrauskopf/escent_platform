class CreateActGenres < ActiveRecord::Migration
  def self.up
    create_table :act_genres do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :act_genres
  end
end
