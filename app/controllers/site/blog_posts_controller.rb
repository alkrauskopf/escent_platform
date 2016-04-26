class Site::BlogPostsController < Site::ApplicationController
  helper :all # include all helpers, all the time
 layout "site", :except =>[:show_blog_post_picture]


  before_filter :blog_load_data #, :except => [:index]
  before_filter :login_require , :only => [:create , :update , :destroy]

  before_filter :load_data , :except => [:index , :show]
  
  def index
    @blog_posts = @blog.blog_posts.active
  end
  
  def create
    return if request.get?
    @blog_post.blog = @blog
    @blog_post.user = @current_user
    if @blog_post.save
      flash[:notice] = "create success"
      redirect_to  :controller => "site/blogs" , :action => "show" , :blog_id => @blog.public_id, :blog_post_id => @blog_post.public_id
    end
  end
  
  def show
    # HACK
    # @blog_post = BlogPost.find_by_title(params[:id].gsub(/[-]/, ' ') )
    @blog_post = BlogPost.find_by_public_id(params[:id])    
    @blogs = @current_organization.blogs.paginate(:page => params[:page], :order => "created_at DESC")    
    @blog = @blog_post.blog
    @comments = @blog_post.comments
  end
  
  def update
    return if request.get?
    @blog_post.attributes = params[:blog_post]
    if @blog_post.save
      flash[:notice] = "update success"
      redirect_to  :controller => "site/blogs" , :action => "show" , :blog_id => @blog.public_id, :blog_post_id => @blog_post.public_id
    end
  end

  def add_post_picture
    return if request.get?
    @blog_post.attributes = params[:blog_post]
    if @blog_post.save
      flash[:notice] = "update success"
      redirect_to  :action => "update" , :blog_id => @blog.public_id, :blog_post_id => @blog_post.public_id
    end
  end
  
  def show_blog_post_picture
    
  end 
  
  def destroy
    @blog_post.destroy
    redirect_to :controller => "site/blogs" , :action => "show" , :blog_id => @blog.public_id
  end
  
  def delete_comment
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to :back
  end
  
  def add_comment    
    @comment = Comment.new(params[:comment])
    @comment.blog_post = @blog_post
    @comment.user = @current_user
    @comment.user_name = @current_user.full_name
    @comment.valid?
#    render :update do |page|
 #     if @comment.errors.present?
 #       page.replace_html "comment_error_div" , error_messages_for(:comment)
#      else
       @comment.save
#        @number = @blog_post.comment_number
#        @blog_post = @comment.blog_post
#        @blog = @comment.blog_post.blog        
#        page.insert_html :bottom , "blog_comment_warp" , :partial => "comment_show"
#        page.replace_html "comment_form_div" , :partial => "comment_form"
 #       page.replace_html "comment_error_div" , ""
        # page.replace_html "comment_warp" , :partial => "comment_show"
 #     end
#    end

   render :partial => "show_make_comments"  
  end
 
  def new_add_comment    
    @comment = Comment.new
    @comment.blog_post = @blog_post
    @comment.user = @current_user
    @comment.body = params[:comment]
    @comment.user_name = @current_user.full_name
    @comment.valid?
    if @comment.save
      # Notifier.deliver_inform_blogger(:blog => @blog, :blog_post => @blog_post, :user => @comment.user, :comment => @comment.body, :fsn_host => request.host_with_port)
      UserMailer.inform_blogger(@blog, @blog_post, @comment.user, @comment.body, request.host_with_port).deliver
    end
   render :partial => "show_make_comments"  
  end 
 
  
private
  def blog_load_data
    @blog = Blog.find_by_public_id(params[:blog_id]) rescue nil
    if @blog
      @feature_post = BlogPost.find_by_public_id(params[:blog_post_id]) rescue nil
      unless @feature_post || @blog.blog_posts.active.empty?
        @feature_post = @blogs.blog_posts.featured.first ? @blogs.blog_posts.featured.first : @blog.blog_posts.active.first
      end
    end    
    # redirect_to :controller => "site/blogs" , :action => "index" if @blog.blank?
  end
  
  def load_data
    @blog_post = BlogPost.find_by_public_id(params[:blog_post_id]) rescue nil || BlogPost.new(params[:blog_post])
    # @blog_post = BlogPost.find_by_title(params[:id])
  end
  
  def login_require
    if  @current_user.blank? 
      @login_url = url_for(:controller => "site", :organization_id => @current_organization)
      flash[:error] = "please log in"
      respond_to do |format|
        format.html { (redirect_to @login_url and return false) }
        format.js do
          render :update do |p|
            p << "location.href = '#{@login_url}';"
          end and return false
        end
      end
      false
    end
      
  end
  
end
