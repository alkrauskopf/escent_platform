class CreateTlActivityTypes < ActiveRecord::Migration
  def self.up
    create_table :tl_activity_types do |t|
      t.string :activity
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :tl_activity_types
  end
end
