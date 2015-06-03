class BlogPost < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :blog
  belongs_to :user  
  # belongs_to :organization
  has_many :comments, :dependent => :destroy
  has_many :blog_post_related_posts, :dependent => :destroy
  has_many  :related_posts, :through => :blog_post_related_posts, :source => :related_post
  
#  has_attached_file :picture, :styles => { :normal => "420x" }, :default_style => :normal

  has_attached_file :picture, :path => ":rails_root/public/blog_posts_images/:id/:basename.:extension", :url => "/blog_posts_images/:id/:basename.:extension"

  named_scope :for_blog, lambda{|blog| {:conditions => ["blog_id = ? ", blog.id]}}
  named_scope :featured, :conditions => ["is_featured = ?", true]
  named_scope :active, :conditions =>["is_active = ?", true], :order => "position"  
  named_scope :not_featured, :conditions => ["is_featured = ?", false], :order => "position"
  named_scope :by_position, :order => "position" 
  named_scope :for_user, lambda{|user| {:conditions => ["user_id = ? ", user.id], :order => "created_at DESC"}}
  named_scope :for_panelist, lambda{|panelist| {:conditions => ["user_id = ? ", panelist.id], :order => "created_at DESC"}}

  
  def to_param  # overridden
    "#{created_at.year}/#{created_at.month}/#{created_at.day}/#{title.parameterize}"
  end
  
  def permalink
    to_param
  end
  
  def user_info
    (user.full_name + ":" rescue "") + "#{created_at}"
  end
  
  def comment_count
    self.comments.size
  end
  
  def comment_number
    self.comments.size > 0 ? self.comments.size - 1 : 0
  end
  
  def clear_feature
    self.update_attributes(:is_featured => false)
  end

  def set_as_feature
    self.blog.blog_posts.each do |post|
        post.clear_feature
    end
    self.update_attributes(:is_featured => true, :is_active => true)
  end  

  def can_be_delete?
    !self.is_active
  end

  def active?
    self.is_active
  end

  def unrelated_posts_for_user(user)
    (user.blog_posts - self.related_posts).select{|p| p != self}
  end

   
end
