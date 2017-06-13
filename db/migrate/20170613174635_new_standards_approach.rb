class NewStandardsApproach < ActiveRecord::Migration
  def up
    add_column :act_masters, :abbrev_old, :string
    execute "UPDATE act_masters SET abbrev_old = abbrev"
  end

  def down
    remove_column :act_masters, :abbrev_old
  end
end
