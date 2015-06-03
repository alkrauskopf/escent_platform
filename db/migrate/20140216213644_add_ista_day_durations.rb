class AddIstaDayDurations < ActiveRecord::Migration
  def self.up
    add_column  :time_allocations, :hrsday_std, :decimal, :precision => 4, :scale=> 2, :default =>6.5
    add_column  :time_allocations, :hrsday_er, :decimal, :precision => 4, :scale=> 2, :default =>4.5
    add_column  :time_allocations, :hrsday_ls, :decimal, :precision => 4, :scale=> 2, :default =>4.5
    remove_column  :time_allocations, :start_time_std
    remove_column  :time_allocations, :end_time_std    
    remove_column  :time_allocations, :start_time_er
    remove_column  :time_allocations, :end_time_er
    remove_column  :time_allocations, :start_time_ls
    remove_column  :time_allocations, :end_time_ls
  end

  def self.down
    add_column  :time_allocations, :start_time_std, :time
    add_column  :time_allocations, :end_time_std, :time   
    add_column  :time_allocations, :start_time_er, :time
    add_column  :time_allocations, :end_time_er, :time
    add_column  :time_allocations, :start_time_ls, :time
    add_column  :time_allocations, :end_time_ls, :time
    remove_column  :time_allocations, :hrsday_std
    remove_column  :time_allocations, :hrsday_er
    remove_column  :time_allocations, :hrsday_ls
  end
end
