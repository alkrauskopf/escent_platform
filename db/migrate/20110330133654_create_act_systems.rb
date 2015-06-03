class CreateActSystems < ActiveRecord::Migration
  def self.up
    create_table :act_systems do |t|
      t.string :addrev
      t.string :name
      t.string :info_source
      t.boolean :is_national

      t.timestamps
    end
  end

  def self.down
    drop_table :act_systems
  end
end
