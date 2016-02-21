class BlogPostRelatedPost < ActiveRecord::Base

  belongs_to :blog_post
  belongs_to :related_post, :class_name => 'BlogPost', :foreign_key=>'related_post_id'
  scope :for_related, lambda{|rp_id| {:conditions => ["related_post_id = ? ", rp_id]}}

end
