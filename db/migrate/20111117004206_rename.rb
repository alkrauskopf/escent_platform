class Rename < ActiveRecord::Migration
  def self.up

  rename_column :bios, :bio_type, :bioable_type

  end

  def self.down

  rename_column :bios, :bioable_type, :bio_type

  end
end
