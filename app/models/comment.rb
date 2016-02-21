class Comment < ActiveRecord::Base
  belongs_to :blog_post
  belongs_to :user
  
  validates_presence_of :user_name
  validates_presence_of :body

  scope :last_first, :order => 'created_at DESC'
  
  def user_info
    "#{user.fullname + ":" rescue nil}#{created_at}"
  end
  
end
