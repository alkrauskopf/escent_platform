class CreateIstaGroups < ActiveRecord::Migration
  def self.up
    create_table :ista_groups do |t|
      t.string :name
      t.string :subject_list
      t.string :subject_list_name
      t.string :support_name

      t.timestamps
    end
  end

  def self.down
    drop_table :ista_groups
  end
end
