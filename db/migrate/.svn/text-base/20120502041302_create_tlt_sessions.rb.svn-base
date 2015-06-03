class CreateTltSessions < ActiveRecord::Migration
  def self.up
    create_table :tlt_sessions do |t|
      t.integer :classroom_id
      t.integer :user_id
      t.integer :tracker_id
      t.string :lesson
      t.integer :students
      t.text :observations
      t.text :conclusions

      t.timestamps
    end

  end

  def self.down
    drop_table :tlt_sessions
  end
end
