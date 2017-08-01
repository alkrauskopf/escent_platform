class AddGuardianEmail < ActiveRecord::Migration
  def up
    add_column :users, :guardian_email, :string
  end

  def down
    remove_column :users, :guardian_email
  end
end
