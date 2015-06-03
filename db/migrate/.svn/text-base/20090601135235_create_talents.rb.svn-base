class CreateTalents < ActiveRecord::Migration
  def self.up
    create_table :talents, :force => true do |t|
      t.integer :user_id
      t.string :name
    end
  end

  def self.down
    drop_table :talents
  end
end