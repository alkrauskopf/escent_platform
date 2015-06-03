class CreateHomeworks < ActiveRecord::Migration
  def self.up
    create_table :homeworks do |t|
      t.integer :topic_id
      t.string :title
      t.integer :user_id
      t.integer :teacher_id
      t.text :comments
      t.string :homework_file_name
      t.string :home_content_type
      t.integer :content_object_type_id
      t.integer :homework_file_size
      t.datetime :first_viewed

      t.timestamps
    end
  end

  def self.down
    drop_table :homeworks
  end
end
