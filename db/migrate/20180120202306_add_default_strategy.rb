class AddDefaultStrategy < ActiveRecord::Migration
  def up
    add_column :act_strategies, :is_default, :boolean, :default=>false
  end

  def down
    remove_column :act_strategies, :is_default
  end
end
