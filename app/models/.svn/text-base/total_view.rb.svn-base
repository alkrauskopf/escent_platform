class TotalView < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  
  def increment
   self.class.update_all "views = views + 1", "id = #{self.id}"
   self.views
  end
end
