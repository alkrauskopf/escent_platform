class CreateTchrOptions < ActiveRecord::Migration
  def self.up
    create_table :tchr_options do |t|
      t.integer :user_id
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end

  def self.down
    drop_table :tchr_options
  end
end
