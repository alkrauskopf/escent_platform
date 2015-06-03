class CreateClassroomContents < ActiveRecord::Migration
  def self.up
    create_table :classroom_contents do |t|
      t.integer :classroom_id
      t.integer :content_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :classroom_contents
  end
end
