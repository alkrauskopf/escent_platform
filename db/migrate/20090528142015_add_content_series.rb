class AddContentSeries < ActiveRecord::Migration
  def self.up
    add_column :contents, :series, :string, :limit => 1000    
  end
  
  def self.down
    remove_column :contents, :series
  end
end
