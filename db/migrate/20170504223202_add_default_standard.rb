class AddDefaultStandard < ActiveRecord::Migration
  def up
    add_column :act_masters, :is_default, :boolean, :default => false, :uniq => true

    execute "UPDATE act_masters SET is_default = 1 WHERE abbrev = 'ACT'"
  end

  def down
    remove_column :act_masters, :is_default
  end
end
