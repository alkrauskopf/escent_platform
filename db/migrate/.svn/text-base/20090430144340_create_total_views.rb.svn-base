class CreateTotalViews < ActiveRecord::Migration
  def self.up
    create_table :total_views do |t|
      t.integer :entity_id
      t.string  :entity_type, :limit => 32
      t.integer :views, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :total_views
  end
end
