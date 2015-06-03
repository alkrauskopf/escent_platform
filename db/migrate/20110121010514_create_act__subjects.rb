class CreateAct_subjects < ActiveRecord::Migration
  def self.up
    create_table :act_subjects do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :act_subjects
  end
end
