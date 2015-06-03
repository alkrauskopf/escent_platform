module Site::BlogsHelper
  def image_tag_with_link(blog, user)
    blog_post = blog.blog_posts.find_all_by_user_id(user.id).last
    if user.picture
      if blog_post
        link_to "#{image_tag user.picture.url(:thumb)}", "/#{blog_post.public_id}/blog/#{blog_post.permalink}", :blog_post_id => blog_post.id
      else
        link_to "#{image_tag user.picture.url(:thumb)}", {:controller => "site/blogs" , :action => "show" , :blog_id => blog, :blog_post_id => blog_post.public_id}
      end
    end
  end
end
