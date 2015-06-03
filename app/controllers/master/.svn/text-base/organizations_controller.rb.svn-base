class Master::OrganizationsController < Master::ApplicationController
  layout "master"
  before_filter :find_organization, :only => [:edit, :show, :delete]
  
  def index
    @organizations = Organization.find :all
  end
  
  def new
    @organization = Organization.new
    if request.post?
      @organization = Organization.new(params[:organization])
      @organization.is_default = false
      if @organization.save
        flash[:notice] = "Successfully created organization #{@organization.name}."
        redirect_to :action => :index
      else
        flash[:error] = @organization.errors.full_messages.to_sentence
      end
    end
  end
  
  def edit
    if request.post?
      if @organization.update_attributes(params[:organization])
          flash[:notice] = "Successfully updated organization #{@organization.name}."
          redirect_to :action => :index
      else
        flash[:error] = @organization.errors.full_messages.to_sentence
      end
    end
  end

  def show
  end
  def list
  end  
  def ownership
  end
  def app_useability
  end
  def toggle_co_owner
    @app = CoopApp.find_by_id(params[:app_id])  
    app_org = @app.coop_app_organizations.select{|o| o.organization_id == params[:owner_id].to_i}.first  
    if app_org
        app_org.update_attributes(:is_owner => !app_org.is_owner)
    end
      render :partial => "master/organizations/owner_maintenance", :locals => {:app => @app}
  end

  def change_app_master
    @app = CoopApp.find_by_id(params[:app_id])  
    if @app
        @app.update_attributes(:owner_id => params[:master_id].to_i)
    end
      render :partial => "master/organizations/owner_maintenance", :locals => {:app => @app}
  end


  def change_app_discussion_owner
    @app = CoopApp.find_by_id(params[:app_id])  
    if @app.app_discussion
        @app.app_discussion.update_attributes(:organization_id => params[:owner_id].to_i)
    else
      app_discuss = AppDiscussion.new
      app_discuss.organization_id = params[:owner_id].to_i
      @app.app_discussion = app_discuss
    end
      render :partial => "master/organizations/owner_maintenance", :locals => {:app => @app}
  end

  def change_app_useability
    app = CoopApp.find_by_id(params[:app_id]) rescue nil
    org = Organization.find_by_id(params[:org_id]) rescue nil
    if app && org
      if org.appl_disallowed?(app)
        unless org.appl_owner?(app) || org.appl_selected?(app) 
          org.coop_apps.delete app
        else
          org.coop_app_organizations.for_app(app).first.update_attribute("is_allowed", true)
        end
      else
        unless org.coop_apps.include?(app)
          selected_app = CoopAppOrganization.new
          selected_app.is_selected = false
          selected_app.is_allowed = false
          selected_app.organization_id = org.id
          selected_app.coop_app_id = app.id
          selected_app.save
        else
          org.coop_app_organizations.for_app(app).first.update_attribute("is_allowed", false)
        end
      end
    end
      render :partial => "master/organizations/app_useability", :locals => {:app => app}
  end
  
  def owner_maintenace
    @app = CoopApp.find_by_id(params[:app_id]) rescue nil
  end 
  
  def delete
    if request.post?
     @organization.destroy
      flash[:notice] = "Successfully removed organization #{@organization.name}."
      redirect_to :action => :index
    end
  end

  
  protected
  
  def find_organization
    @organization = Organization.find(params[:id])
  end
end
