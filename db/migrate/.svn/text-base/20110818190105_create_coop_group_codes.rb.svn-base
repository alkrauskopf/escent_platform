class CreateCoopGroupCodes < ActiveRecord::Migration
  def self.up
    create_table :coop_group_codes do |t|
      t.string :code
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :coop_group_codes
  end
end
