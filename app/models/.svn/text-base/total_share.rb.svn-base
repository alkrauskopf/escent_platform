class TotalShare < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  
  def increment
   self.class.update_all "shares = shares + 1", "id = #{self.id}"
   self.shares
  end
end
