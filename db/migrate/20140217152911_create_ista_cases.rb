class CreateIstaCases < ActiveRecord::Migration
  def self.up
    create_table :ista_cases do |t|
      t.integer :user_id
      t.integer :organization_id
      t.integer :ista_step_id
      t.string :title
      t.integer :case_students
      t.boolean :is_active, :default=>false
      t.boolean :is_final, :default=>false
      t.date :final_date
      t.boolean :is_archived, :default=>false
      t.decimal :daysweek
      t.decimal :hrsday_std
      t.decimal :daysyear_std
      t.decimal :hrsday_er
      t.decimal :daysyear_er
      t.decimal :hrsday_ls
      t.decimal :daysyear_ls

      t.timestamps
    end
    add_index :ista_cases, :organization_id
    add_index :ista_cases, :user_id
    add_index :ista_cases, :ista_step_id
  end

  def self.down
    drop_table :ista_cases
  end
end
