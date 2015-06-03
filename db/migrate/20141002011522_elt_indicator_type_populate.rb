class EltIndicatorTypePopulate < ActiveRecord::Migration
  def self.up
    execute "UPDATE elt_indicators SET elt_type_id = 101" 
  end

  def self.down
  end
end
