class AddFixIstaDecimalFields < ActiveRecord::Migration
  def self.up
    remove_column  :ista_cases, :hrsday_std
    add_column  :ista_cases, :hrsday_std, :decimal, :precision => 4, :scale=> 2
    remove_column  :ista_cases, :hrsday_er
    add_column  :ista_cases, :hrsday_er, :decimal, :precision => 4, :scale=> 2
    remove_column  :ista_cases, :hrsday_ls
    add_column  :ista_cases, :hrsday_ls, :decimal, :precision => 4, :scale=> 2
    remove_column  :ista_cases, :daysweek
    add_column  :ista_cases, :daysweek, :decimal, :precision => 2, :scale=> 1
    remove_column  :ista_cases, :daysyear_std
    add_column  :ista_cases, :daysyear_std, :decimal, :precision => 4, :scale=> 1
    remove_column  :ista_cases, :daysyear_er
    add_column  :ista_cases, :daysyear_er, :decimal, :precision => 4, :scale=> 1
    remove_column  :ista_cases, :daysyear_ls
    add_column  :ista_cases, :daysyear_ls, :decimal, :precision => 4, :scale=> 1
  end

  def self.down
    remove_column  :ista_cases, :hrsday_std
    add_column  :ista_cases, :hrsday_std, :decimal
    remove_column  :ista_cases, :hrsday_er
    add_column  :ista_cases, :hrsday_er, :decimal
    remove_column  :ista_cases, :hrsday_ls
    add_column  :ista_cases, :hrsday_ls, :decimal
    remove_column  :ista_cases, :daysweek
    add_column  :ista_cases, :daysweek, :decimal
    remove_column  :ista_cases, :daysyear_std
    add_column  :ista_cases, :daysyear_std, :decimal
    remove_column  :ista_cases, :daysyear_er
    add_column  :ista_cases, :daysyear_er, :decimal
    remove_column  :ista_cases, :daysyear_ls
    add_column  :ista_cases, :daysyear_ls, :decimal

  end
end
