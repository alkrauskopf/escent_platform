class AddGenreIdToRelReading < ActiveRecord::Migration
  def self.up
    add_column :act_rel_readings, :act_genre_id, :integer
    execute "UPDATE act_rel_readings SET act_genre_id = 99" 
  
  end

  def self.down
    remove_column :act_rel_readings, :act_genre_id
  end
end
