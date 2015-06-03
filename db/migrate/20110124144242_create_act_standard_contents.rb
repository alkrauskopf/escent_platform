class CreateActStandardContents < ActiveRecord::Migration
  def self.up
    create_table :act_standard_contents do |t|
      t.integer :content_id
      t.integer :act_standard_id

      t.timestamps
    end
  end

  def self.down
    drop_table :act_standard_contents
  end
end
