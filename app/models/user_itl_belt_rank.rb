class UserItlBeltRank < ActiveRecord::Base


    belongs_to :user
    belongs_to :itl_belt_rank

 validates_presence_of :justification, :message => 'Please note justification.'
    
end
