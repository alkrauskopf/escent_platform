class AddEomonthToTchrOptions < ActiveRecord::Migration
  def self.up

    add_column :tchr_options, :end_is_current_date, :boolean 
    execute "UPDATE tchr_options SET end_is_current_date = 1"    
  end

  def self.down

    remove_column :tchr_options, :end_is_current_date  
  
  end
end
