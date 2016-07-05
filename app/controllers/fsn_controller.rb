class FsnController < ApplicationController
  layout "ep_site2",  :except =>[:model_flash, :select_blog, :show_post]
  
  before_filter :current_user

  def index
    initalialize_parameters
    if (Organization.all.empty? && User.all.empty?)
      redirect_to master_organizations_new_path
    else
      @blog = Blog.find_by_public_id(params[:blog_id]) rescue nil
      if @blog.nil?
        blog_type = BlogType.of_type("OD").first
        @blog = @current_organization.blogs.active.featured.of_type(blog_type).first
      end
      render :layout => "ep_site2"
    end
  end

   private
   
  def initalialize_parameters
    if params[:organization_id]
      @current_organization = Organization.find_by_public_id(params[:organization_id])
    else
     @current_organization = Organization.default
    end
  end
end
