class CreateFolderMasteryLevels < ActiveRecord::Migration
  def change
    create_table :folder_mastery_levels do |t|
      t.integer :folder_id
      t.integer :act_score_range_id

      t.timestamps
    end
    add_index :folder_mastery_levels, :folder_id
    add_index :folder_mastery_levels, :act_score_range_id
  end
end
