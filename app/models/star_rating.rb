class StarRating < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  
  def add(rating)
    self.class.update_all "rating = (rating * votes + #{rating}) / (votes + 1), votes = votes + 1", "id = #{self.id}"
  end
end
