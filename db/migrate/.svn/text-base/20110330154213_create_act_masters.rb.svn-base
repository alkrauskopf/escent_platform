class CreateActMasters < ActiveRecord::Migration
  def self.up
    create_table :act_masters do |t|
      t.string :abbrev
      t.string :name
      t.string :source
      t.boolean :is_national

      t.timestamps
    end
  end

  def self.down
    drop_table :act_masters
  end
end
