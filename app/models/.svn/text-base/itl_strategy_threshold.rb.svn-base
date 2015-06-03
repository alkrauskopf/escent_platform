class ItlStrategyThreshold < ActiveRecord::Base


  belongs_to :tl_activity_type_task

  validates_numericality_of :min_minutes, :greater_than_or_equal_to => 0.0, :message => 'Must Be > 0.0', :allow_nil=>true
  validates_numericality_of :max_minutes, :greater_than_or_equal_to => 0.0, :message => 'Must Be > 0.0', :allow_nil=>true
  validates_numericality_of :min_pct, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100,:message => 'Must Be > 0 & <=100', :allow_nil=>true
  validates_numericality_of :max_pct, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100, :message => 'Must Be > 0 & <=100', :allow_nil=>true
 
  
end
