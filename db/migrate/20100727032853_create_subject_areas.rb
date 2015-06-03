class CreateSubjectAreas < ActiveRecord::Migration
  def self.up
    create_table :subject_areas, :force => true do |t|
      t.integer :content_id
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :subject_areas
  end
end
