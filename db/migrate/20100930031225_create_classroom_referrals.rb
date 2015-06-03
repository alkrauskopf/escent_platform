class CreateClassroomReferrals < ActiveRecord::Migration
  def self.up
    create_table :classroom_referrals do |t|
      t.integer :classroom_id
      t.integer :topic_id

      t.timestamps
    end
  end

  def self.down
    drop_table :classroom_referrals
  end
end
