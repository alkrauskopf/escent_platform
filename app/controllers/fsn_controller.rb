class FsnController < ApplicationController
  layout "ep_site2",  :except =>[:model_flash, :select_blog, :show_post]
  
  before_filter :current_user

  def index
    initalialize_parameters


    if (Organization.all.empty? && User.all.empty?)
      redirect_to :controller=>"/organizations", :action => :register
    else
      @blog = Blog.find_by_public_id(params[:blog_id]) rescue nil
      if @blog.nil?
        blog_type = BlogType.of_type("OD").first
        @blog = @current_organization.blogs.active.featured.of_type(blog_type).first
      end
      render :layout => "ep_site2"
    end
  end
 
  def select_blog
    initalialize_parameters
    @blog = Blog.find_by_public_id(params[:blog_id]) rescue nil
    render :partial => "/fsn/index_ep_body", :locals=> {:blog=> @blog}    
  end

  def show_post
    initalialize_parameters
    @blog_post = BlogPost.find_by_public_id(params[:blog_post_id]) rescue nil
  end
 
  def model_flash
    initalialize_parameters
    @who_we_are_blog = @current_organization.who_we_are_featured
    if @who_we_are_blog
      @thought_post = @who_we_are_blog.blog_posts.not_featured.active.first ? @who_we_are_blog.blog_posts.not_featured.active.first : nil
    end
  end
 
  def contact
    initalialize_parameters
    @first_name = params[:first_name] rescue ""
    @last_name =  params[:last_name] rescue ""
    @email =  params[:email] rescue ""
    @title =  params[:title] rescue ""
    @body =  params[:body] rescue ""
    if params[:captcha_fail]
       flash[:error] = "Security Code Mismatch: Please Try Again." 
    end
  end
 
  
  def contact_us
    initalialize_parameters
    if true #simple_captcha_valid?
      Notifier.deliver_contact_us(params)
      render  :template => "fsn/contact_us_complete"
    else
      @first_name = params[:contact_info][:first_name] 
      @last_name = params[:contact_info][:last_name] 
      @email = params[:contact_info][:email] 
      @title = params[:contact_info][:title] 
      @body = params[:contact_info][:body] 
      flash[:notify] = "CAPTCHA Failed"
      redirect_to :action => :contact, :organization_id => @current_organization, :captcha_fail => true, :first_name => @first_name, :last_name => @last_name, :email => @email, :title => @title, :body => @body
    end
  end

   private
   
  def initalialize_parameters
    if params[:organization_id]
      @current_organization = Organization.find_by_public_id(params[:organization_id])
    else
     @current_organization = Organization.ep_default.first 
    end
  end
end
