class CreateAppMethodLogRatings < ActiveRecord::Migration
  def self.up
    create_table :app_method_log_ratings do |t|
      t.integer :app_method_id
      t.string :label, :limit => 10

      t.timestamps
    end
    add_index :app_method_log_ratings, :app_method_id
  end

  def self.down
    drop_table :app_method_log_ratings
  end
end
