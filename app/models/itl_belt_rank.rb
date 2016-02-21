class ItlBeltRank < ActiveRecord::Base

  has_many :user_itl_belt_ranks, :dependent => :destroy   
  has_many :users, :through => :user_itl_belt_ranks
  has_many :tlt_sessions
  has_many :itl_summaries
  
  scope :white, :conditions => { :rank => "white"}
  scope :black, :conditions => { :rank => "black"}
  scope :none, :conditions => { :rank => "none"}
  scope :all_colors, {:conditions => [ "rank != ?", "none"]}
end
