class AddCaseTeacherIstaCase < ActiveRecord::Migration
  def self.up

    add_column  :ista_cases, :case_teachers, :decimal, :precision => 4, :scale=> 1, :default=>0.0

  end

  def self.down

    remove_column  :ista_cases, :case_teachers

  end
end
