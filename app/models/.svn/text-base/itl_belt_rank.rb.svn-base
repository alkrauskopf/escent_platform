class ItlBeltRank < ActiveRecord::Base

  has_many :user_itl_belt_ranks, :dependent => :destroy   
  has_many :users, :through => :user_itl_belt_ranks
  has_many :tlt_sessions
  has_many :itl_summaries
  
  named_scope :white, :conditions => { :rank => "white"}
  named_scope :black, :conditions => { :rank => "black"}
  named_scope :none, :conditions => { :rank => "none"}
  named_scope :all_colors, {:conditions => [ "rank != ?", "none"]}
end
