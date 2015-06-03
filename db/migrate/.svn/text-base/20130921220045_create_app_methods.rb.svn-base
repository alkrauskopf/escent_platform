class CreateAppMethods < ActiveRecord::Migration
  def self.up
    create_table :app_methods do |t|
      t.integer :coop_app_id
      t.string :abbrev, :limit=>4
      t.string :name, :limit=>40
      t.text :description
      t.boolean :is_timed
      t.integer :position

      t.timestamps
    end
  add_index :app_methods, :coop_app_id
  end

  def self.down
    drop_table :app_methods
  end
end
