class Apps::AppBlogController < ApplicationController

  helper :all # include all helpers, all the time  
  layout "app_blog", :except =>[]

  before_filter :initialize_parameters
  
  def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end



  def index
  end

  def show_app_blog
    @current_organization = @blog.organization   
    @blog.increment_views
  end

  def new_add_comment    
    @comment = Comment.new
    @comment.blog_post = @blog_post
    @comment.user = @current_user
    @comment.body = params[:comment]
    @comment.user_name = @current_user.full_name
    @comment.valid?
    if @comment.save
 #       Notifier.deliver_inform_blogger(:blog => @blog, :blog_post => @blog_post, :user => @comment.user, :comment => @comment.body, :fsn_host => request.host_with_port)
    end
    render :partial => "show_make_comments", :locals=>{:blog_post => @blog_post, :app=>@blog_app} 
  end

  def delete_comment
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to :back
  end

  def share_email
    if @blog 
     # if simple_captcha_valid? || @current_user
      if  @current_user
      sender_emails = params[:email_to].split(/, */)
      sender_emails.each do |sender_email|
        @blog.increment_shares
        # Notifier.deliver_share_app_blog(:organization => @current_organization, :user_name => params[:from_name], :blog_id => @blog.public_id, :recipient => params[:email_to], :message => params[:message], :subject_line => params[:from_name] + ": Discussion Link", :fsn_host => request.host_with_port)
        UserMailer.share_app_blog(@current_organization, params[:from_name], @blog.public_id, :params[:email_to], params[:message], (params[:from_name] + ': Discussion Link'), request.host_with_port).deliver
      end
      flash[:notice] = sender_emails.size.to_s + " Email" + (sender_emails.size == 1 ? " ":"s ") + "Sent"
    else
      flash[:error] = "Captcha String Incorrect"
    end
    else
      flash[:error] = "Invalid Post Please Close Window"
    end
    render :partial => "apps/app_blog/share_email_box", :locals=>{:blog=>@blog, :user_name => params[:from_name], :message=> params[:message], :to_email=>params[:email_to] } 
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
   end

  def current_user
    @current_user ||= (session[:user_id] && User.find(session[:user_id]) rescue nil) || nil
  end

  def current_organization
    @current_organization ||= (Organization.find_by_public_id(params[:organization_id]) rescue Organization.default)
  end
  def admin?
    @admin = @current_user.has_authority?(@current_organization, AuthorizationLevel.app_administrator(CoopApp.core)) rescue false
  end
 
  def blogger?
    @blogger = @current_organization.bloggers.include?(@current_user) rescue false
  end

  def current_blog
    @blog = Blog.find_by_public_id(params[:blog_id]) rescue nil
  end

  def current_post
    @blog_post = BlogPost.find_by_public_id(params[:blog_post_id]) rescue nil
    unless @blog_post
      if @blog
        @blog_post = @blog.blog_posts.featured.active.first rescue nil
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
  
  


  
  def authorization_check
    unless @admin || @blogger
      redirect_to :controller => "/site/site", :action => :static_organization, :organization_id => Organization.ep_default.first
    end
  end

  def check_for_dup_feature
     dup_blogs = @current_organization.blogs.select{|b| b.feature && b.blog_type_id == params[:blog][:blog_type_id].to_i}
      unless dup_blogs.size == 0
          @blog.clear_feature
      end 
  end  

end
