class CreateUserGuardians < ActiveRecord::Migration
  def change
    remove_column :users, :guardian_email
    create_table :user_guardians do |t|
      t.integer :user_id
      t.string :email_address
      t.string :first_name
      t.string :last_name
      t.string :phone

      t.timestamps
    end
    add_index :user_guardians, [:user_id]
  end
end
