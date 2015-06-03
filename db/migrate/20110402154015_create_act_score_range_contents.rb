class CreateActScoreRangeContents < ActiveRecord::Migration
  def self.up
    create_table :act_score_range_contents do |t|
      t.integer :content_id
      t.integer :act_score_range_id

      t.timestamps
    end
  end

  def self.down
    drop_table :act_score_range_contents
  end
end
