class CreateAct_standards < ActiveRecord::Migration
  def self.up
    create_table :act_standards do |t|
      t.integer :act_subject_id
      t.text :name

      t.timestamps
    end
  end

  def self.down
    drop_table :act_standards
  end
end
