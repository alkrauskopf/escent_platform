class Admin::AssociatesController < Admin::ApplicationController
  layout "/admin/associates/layout", :except => [:contact, :index]
  
  protect_from_forgery :except => :change_member_status
  
  def index
    
  end
  
  def change_member_status
    @user = User.find_by_public_id params[:id]
    if request.xhr?
      if params[:status] == "Yes"
        @user.add_as_member_to @current_organization
        flash[:notice] = "#{@user.full_name} has been added as a member to this organization"
      else
        @user.remove_as_member_from @current_organization
        flash[:notice] = "#{@user.full_name} has been removed as a member from this organization"
      end
      text = @user.member_of?(@current_organization) ? "Yes" : "No"
      render :text => text
    end
  end
  
  def remove_association
    @user = User.find_by_public_id params[:id]
    @user.remove_as_associates_from @current_organization
    flash[:notice] = "#{@user.full_name} has been removed from this organization"
    redirect_to :action => :index, :organization_id => @current_organization
  end
  
  def contact
    @user = User.find_by_public_id params[:id]
    if request.post?
      options = {:user => to_user, :subject => params[:email_archive][:subject], :html_body => params[:email_archive][:html_body]}
      UserMailer.contact(@current_user.preferred_email, options).deliver
      respond_to do |format|
        format.js do
          responds_to_parent do
            render :update do |page|
              page.replace_html "associates_panel", :partial => 'associates', :object => @current_organization
            end
          end          
        end
      end
    end
  end
end
