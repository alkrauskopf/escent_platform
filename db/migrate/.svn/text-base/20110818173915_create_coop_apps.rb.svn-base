class CreateCoopApps < ActiveRecord::Migration
  def self.up
    create_table :coop_apps do |t|
      t.string :name
      t.string :abbrev

      t.timestamps
    end
  end

  def self.down
    drop_table :coop_apps
  end
end
