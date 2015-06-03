class Site::BlogsController < Site::ApplicationController
 
   helper :all # include all helpers, all the time
 
  protect_from_forgery :except => [:share_blog]  
  before_filter :load_data , :except => [:index]
  layout "blog", :except =>[:share_blog] 

  def index
    @blogs = @current_organization.blogs.active.paginate(:page => params[:page], :order => "created_at DESC")
  end
  
  def create
    #pp request.get?
    return if request.get?
    @blog.organization_id = @current_organization.id
    @blog.user = @current_user
    if @blog.save
      flash[:notice] = "create success"
      redirect_to :action => "index"
    end
  end
  
  def show
    @blogs = @current_organization.blogs.paginate(:page => params[:page], :order => "created_at DESC")    
    @blog_posts = @blog.blog_posts.active

  end  
  
  def share_blog
    if request.xhr?
      sender_emails = params[:email_archive][:sender_email].split(/, */)
      sender_emails.each do |sender_email|
        @current_organization.metrics << Metric.new(3 , @current_user.id)
        Notifier.deliver_share_blog(:blog => @blog, :user => @current_user, :sender_email => sender_email, :message => params[:email_archive][:plain_body], :fsn_host => request.host_with_port)
      end
      render :text => ""
    end
  end
  
  private
  
  def load_data
    @blog = Blog.find_by_public_id(params[:blog_id]) rescue nil || Blog.new(params[:blog])
  end
  
end
