class AddActivePositionStrands < ActiveRecord::Migration
  def up
    add_column :act_standards, :is_active, :boolean, :default => false
    add_column :act_standards, :pos, :integer, :default => 0

    execute "UPDATE act_standards SET is_active = 1"
  end

  def down
    remove_column :act_standards, :is_active
    remove_column :act_standards, :pos
  end
end
