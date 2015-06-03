class CreateBios < ActiveRecord::Migration
  def self.up
    create_table :bios do |t|
      t.integer :bioable_id
      t.string :bio_type
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :bios
  end
end
