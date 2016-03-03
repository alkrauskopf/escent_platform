class Apps::BlogsController < ApplicationController
  helper :all # include all helpers, all the time
 layout "panel_blog", :except =>[:panelist_info, :panelist_activity, :list_app_blogs, :list_blogs, :toggle_blog_activate, :maintain_blogs, :blog_overview, :show_blog_posting, :show_blog_post_flash, :show_blog_post_picture, :add_post_picture, :show_blog_picture,:show_blog_flash,:destroy_blog, :toggle_blog_commentable, :toggle_blog_feature, :edit_blog_sequence, :toggle_blog_post_activate, :toggle_blog_post_feature, :edit_blog_post_sequence]
  

  before_filter :initialize_parameters
  
 def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end
  

  def index
    CoopApp.blog.increment_views
    authorization_check
  end

  def main_index
    @blogs = @current_organization.blogs.paginate(:page => params[:page], :order => "created_at DESC")
  end
  
  def main_show
    @blogs = @current_organization.blogs.paginate(:page => params[:page], :order => "created_at DESC")    
    @blog_posts = @blog.blog_posts.paginate(:page => params[:page], :order => "created_at DESC")
  end  

  def show_app_blog
    @blog_posts = @blog.blog_posts.active   
  end
   
  def share_blog
    if request.xhr?
      sender_emails = params[:email_archive][:sender_email].split(/, */)
      sender_emails.each do |sender_email|
        @current_organization.metrics << Metric.new(3 , @current_user.id)
        Notifier.deliver_share_blog(:blog => @blog, :user => @current_user, :sender_email => sender_email, :message => params[:email_archive][:plain_body])
      end
      render :text => ""
    end
  end

  def create_blog

    blog = Blog.new
    blog.creator_id = @current_user.id
    blog.organization_id = @current_organization.id
    blog.title = params[:title]
    blog.blog_type_id = @blog_type.id
    blog.coop_app_id = @blog_app.id
    blog.position = @current_organization.blogs.of_type(@blog_type).for_app(@blog_app).size + 1
    blog.save
    render :partial => "/apps/blogs/list_blogs", :locals => {:b_type => @blog_type, :blog_app => @blog_app}

  end

  def add_blog
    if @admin
      @blog = Blog.new

      if params[:function] == "Create"
        @blog = @current_organization.blogs.new(params[:blog])
        @blog.creator_id = @current_user.id
        if params[:blog][:blog_type_id].empty?
          @blog.blog_type_id = BlogType.pov.first.id rescue 10
        end
        @blog.position = @current_organization.blogs.size + 1
        if @blog.save
          redirect_to :action => 'index', :organization_id => @current_organization, :user_id => @current_user
        else 
          flash[:error] = @blog.errors.full_messages.to_sentence 
        end
      end  
    end
   end  

  def edit_blog
    if @admin    

      if params[:function] == "Update"

         unless @blog.blog_type_id == params[:blog][:blog_type_id].to_i
           check_for_dup_feature
         end
        unless params[:coop][:app] == ""
          @blog.coop_app_id = params[:coop][:app].to_i
        end
         if @blog.update_attributes(params[:blog])
          flash[:notice] = "Update Successful.   CLOSE WINDOW"
          else 
          flash[:error] = @blog.errors.full_messages.to_sentence 
        end
      end
    end
  end

  def create_post
    @blog_post = BlogPost.new
    if @blog.users.include?(@current_user) && params[:function] == "Add"
      @blog_post = @blog.blog_posts.new
      @blog_post.title = params[:blog_post][:title]
      @blog_post.pov = params[:blog_post][:pov]
      @blog_post.body = params[:blog_post][:body]
      @blog_post.position = params[:blog_post][:position]
      @blog_post.user = @current_user
      if @blog_post.save
        redirect_to  :action => "edit_post" , :blog_id => @blog.public_id, :blog_post_id => @blog_post.public_id, :flash_notice => "Blog Post Created"
      else 
        flash[:error] = @blog_post.errors.full_messages.to_sentence 
      end
    end
  end

  def add_post
    if @blog.users.include?(@current_user)
      @blog_post = @blog.blog_posts.new
      @blog_post.title = params[:title]
      @blog_post.pov = params[:pov]
      @blog_post.body = params[:body]
      @blog_post.position = params[:position]
      @blog_post.blog = @blog
      @blog_post.user = @current_user
      if @blog_post.save
        flash[:notice] = "Blog Post Created.   CLOSE WINDOW"
        redirect_to  :action => "edit_post" , :blog_id => @blog.public_id, :blog_post_id => @blog_post.public_id
      else 
        flash[:error] = @blog_post.errors.full_messages.to_sentence 
      end
    end  
      render :partial => "apps/blogs/post_form", :locals=>{:blog => @blog, :blog_post => @blog_post, :function=>"New"} 
  end

  def edit_post
    flash[:notice] = params[:flash_notice] ? params[:flash_notice] : nil
    if (@blog_poster || @admin) && params[:function]
      if @blog_post.update_attributes(:title=>params[:blog_post][:title], :pov => params[:blog_post][:pov], :body => params[:blog_post][:body], :position => params[:blog_post][:position])
        flash[:notice] = "Update Successful."
      else 
        flash[:error] = @blog_post.errors.full_messages.to_sentence 
      end
    end
  end
 
 def delete_blog_post
  if @admin || @blog_poster
    if @blog_post.can_be_delete?
      @blog_post.destroy
    end
  end
   render :partial => "blog_post_listings"  
 end
 
  def add_post_picture
    return if request.get?
    if @blog_poster || @admin
    @blog_post.attributes = params[:blog_post]
      if @blog_post.save
      flash[:notice] = "update success"
      end
    end
   redirect_to  :action => "edit_post" , :blog_id => @blog.public_id, :blog_post_id => @blog_post.public_id
  end
  
  def remove_post_flash
    return if request.get?
    if @blog_poster || @admin
    @blog_post.update_attributes(:picture_file_name => nil, :picture_content_type => nil, :picture_file_size => nil)
    end
   redirect_to  :action => "edit_post" , :blog_id => @blog.public_id, :blog_post_id => @blog_post.public_id
  end
 
  def panelist_activity
    
  end
 
  def panelist_info
    
  end  
  def show_blog_post_picture
    
  end 
 
  def show_blog_post_flash
    
  end

 def maintain_blogs

 end

 def list_blogs

 end


 def edit_blog_sequence
   blog_type = @blog ? @blog.blog_type : BlogType.for_app.first
   if @admin
   blogs = @current_organization.blogs.for_type(@blog).sort_by{|b| b.position} rescue []
   blogs.each_with_index do|blog,idx|
   if blog.id == @blog.id
      if params[:direction]=="up" && idx>0
          base_position = blog.position
          blog.update_attributes(:position => blogs[idx-1].position)
          blogs[idx-1].update_attributes(:position => base_position)
       end
      if params[:direction]=="down" && (idx+1)<blogs.size
          base_position = blog.position
          blog.update_attributes(:position => blogs[idx+1].position)
          blogs[idx+1].update_attributes(:position => base_position)
       end 
      @current_organization.sequence_blogs_of_type(@blog)        
    end
   end

  end
   render :partial => "blog_listings", :locals => {:b_type => blog_type, :blog_app => @blog_app ? @blog_app : nil}   
 end

 def edit_blog_post_sequence
   if @admin 
   posts = @blog.blog_posts.by_position rescue []
   posts.each_with_index do|post,idx|
   if post.id == @blog_post.id
      if params[:direction]=="up" && idx>0
          base_position = post.position
          post.update_attributes(:position => posts[idx-1].position)
          posts[idx-1].update_attributes(:position => base_position)
       end
      if params[:direction]=="down" && (idx+1)<posts.size
          base_position = post.position
          post.update_attributes(:position => posts[idx+1].position)
          posts[idx+1].update_attributes(:position => base_position)
       end  
    end
   end
  @blog.sequence_posts
  end
  render :partial => "blog_post_listings"  
 end

 def assign_related_post
  related_post = BlogPost.find_by_id(params[:related_post_id]) rescue nil
  if @blog_post.related_posts.include?(related_post)
    @blog_post.blog_post_related_posts.for_related(related_post.id).destroy_all
  else
    @blog_post.related_posts<<related_post
  end
  render :partial => "apps/blogs/related_posts", :locals=>{:blog_post => @blog_post}
 end

 def toggle_blog_post_activate
    if @admin || @blog_poster
    if @blog_post
      @blog_post.update_attributes(:is_active =>!@blog_post.is_active)
    end
  end
   render :partial => "blog_post_listings"  
 end
 
 def toggle_blog_post_feature
   if @admin 
    if @blog_post
    if   @blog_post.is_featured
      @blog_post.clear_feature
     else
       @blog_post.set_as_feature
    end
    end
   end
   render :partial => "blog_post_listings"  
 end

 def reset_views
   if @admin 
    if @blog
      @blog.reset_views
    end
   end
   render :partial => "blog_listings", :locals => {:b_type => @blog_type, :blog_app => @blog_app ? @blog_app : nil}  
 end

 def toggle_blog_activate
   if @admin 
    if @blog
    if   @blog.active
      @blog.set_as_inactive
     else
       @blog.set_as_active
    end
    end
   end
   render :partial => "blog_listings", :locals => {:b_type => @blog_type, :blog_app => @blog_app ? @blog_app : nil}  
 end
 
 def toggle_blog_feature
    blog_type = @blog ? @blog.blog_type : BlogType.for_app.first
    if @admin
    if @blog
    if   @blog.feature
      @blog.clear_feature
     else
       @blog.set_as_feature
    end
    end
   end
   render :partial => "blog_listings", :locals => {:b_type => blog_type, :blog_app => @blog_app ? @blog_app : nil}
 end

 def toggle_blog_commentable
    blog_type = @blog ? @blog.blog_type : BlogType.for_app.first
    if @admin
    if @blog
     @blog.update_attributes(:is_commentable =>!@blog.is_commentable)
    end
   end
   render :partial => "blog_listings", :locals => {:b_type => blog_type, :blog_app => @blog_app ? @blog_app : nil}
 end

  def add_remove_blogger
   if @admin
    if @blog
      blogger = User.find_by_public_id(params[:panelist_id]) rescue nil
      if @blog.users.include?(blogger)
        @blog.users.delete blogger
        else
       @blog.users << blogger   
      end
    end  
    end
    render :partial => "add_to_panel", :layout => false
  end

  def show_blog_flash
    
  end
  
  def show_blog_picture
    
  end 

  def add_blog_picture
    return if request.get?
    @blog.attributes = params[:blog]
    if @blog.save
      flash[:notice] = "update success"
      redirect_to  :action => "edit_blog" , :blog_id => @blog.public_id, :organization_id => @current_organization
    end
  end

  def add_blog_flash

    @blog.attributes = params[:blog]
      if @blog.save
        flash[:notice] = "update success"
      end
    redirect_to  :action => "edit_blog", :blog_id => @blog.public_id, :organization_id => @current_organization
  end

  def remove_blog_flash
    return if request.get?
    if @blog_poster || @admin
      @blog.update_attributes(:picture_file_name => nil, :picture_content_type => nil, :picture_file_size => nil)
    end
   redirect_to  :action => "edit_blog", :blog_id => @blog.public_id, :organization_id => @current_organization
  end

  def destroy_blog
   blog_type = @blog.blog_type
   if @admin
    if @blog.can_be_delete?
      @blog.destroy
    end
   end
   render :partial => "blog_listings", :locals => {:b_type => blog_type, :blog_app => @blog_app ? @blog_app : nil} 
  end 
 
  def blog_overview
  end

  def show_blog_posting
    
  end
  
   private

 def initialize_parameters
    current_organization
    current_user
    current_blog
    current_post
    current_blog_type
    possible_bloggers
    blogger?
    admin?
    if params[:blog_app]
      @blog_app = CoopApp.find_by_public_id(params[:blog_app]) rescue nil
    end
    @app = CoopApp.blog
    if params[:panelist_id]
      @panelist = User.find_by_public_id(params[:panelist_id]) rescue nil
    end   
   end

  
  def authorization_check
    unless @admin || @blogger
      redirect_to :controller => "/site/site", :action => :static_organization, :organization_id => Organization.ep_default.first
    end
  end
  
  def admin?
    @admin = @current_user. blog_admin_for_org?(@current_organization)
  end
 
  def blogger?
    @blogger = @current_user.panelist_for_org?(@current_organization)
  end

  def current_blog
    @blog = Blog.find_by_public_id(params[:blog_id]) rescue nil
  end

  def current_post
    @blog_post = BlogPost.find_by_public_id(params[:blog_post_id]) rescue nil
    unless @blog_post
      if @blog
        @blog_post = @blog.blog_posts.featured.first rescue nil
        unless @blog_post
        @blog_post = @blog.blog_posts.active.first rescue nil
        end
      end
   end
    if @blog_post
      @blog_poster = (@blog_post.user == @current_user) ? true : false 
    end
  end

  def current_blog_type
    @blog_type = BlogType.find_by_public_id(params[:blog_type_id]) rescue nil
  end

  def possible_bloggers
    @people = @blog ? (@current_organization.bloggers - @blog.users): @current_organization.bloggers
  end

  def current_user
    @current_user ||= (session[:user_id] && User.find(session[:user_id]) rescue nil) || nil
  end

  def current_organization
    @current_organization ||= (Organization.find_by_public_id(params[:organization_id]) rescue Organization.default)
  end

  def check_for_dup_feature
     dup_blogs = @current_organization.blogs.select{|b| b.feature && b.blog_type_id == params[:blog][:blog_type_id].to_i}
      unless dup_blogs.size == 0
          @blog.clear_feature
      end 
  end  

end
