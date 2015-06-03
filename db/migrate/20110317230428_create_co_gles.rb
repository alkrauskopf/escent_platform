class CreateCoGles < ActiveRecord::Migration
  def self.up
    create_table :co_gles do |t|
      t.integer :co_standard_id
      t.string :skill
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :co_gles
  end
end
