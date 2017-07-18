class EmptyContentGarbageTablesColumns < ActiveRecord::Migration
  def up
    drop_table :contents4
  end

  def down
  end
end
