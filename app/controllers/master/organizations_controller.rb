class Master::OrganizationsController < Master::ApplicationController
  layout "crud"
  before_filter :find_organization, :only => [:edit, :show, :delete]
  
  def index
    @organizations = Organization.all
  end


  def new
    if request.post?
      @organization = Organization.new(params[:organization])
      @address = @organization.addresses.new(params[:address])

      if params[:accept_tos].nil?
        flash[:error] = "You must agree to the terms of service"
      else
        if params[:no_website].nil? && @organization.web_site_url.empty? then
          flash[:error] = "Website URL is required. If you do not have a website check the Don't have a Web Site checkbox."
        else
          if @address.save
            @organization.is_default = Organization.all.size == 0 ? true : false
            if  @organization.save
              @address.organization = @organization
              if @current_user then @current_user.add_as_administrator_to(@organization) end
              if @current_user then  @current_user.add_as_friend_to(@organization) end
              @organization.set_default_style_settings
              @address.organization_id = Organization.with_type_id(@organization.organization_type_id).select{|o| o.name == @organization.name}.last.id
              @address.save
              redirect_to :action => :registration_successful, :organization_id => @organization
            else
              @address.destroy
              flash[:error] = @organization.errors.full_messages.to_sentence
            end
          else
            flash[:error] = @address.errors.full_messages.to_sentence
          end
        end
      end
    else

      @organization = Organization.new()
      @organization.organization_type_id = nil
      @address = @organization.addresses.empty? ? @organization.addresses.new : @organization.addresses.physical.first
    end
  end

  def registration_successful
    @saved_org = Organization.find_by_public_id(params[:organization_id])
    if @saved_org
      create_app_settings(CoopApp.core, @saved_org, false, true, true, CoopApp.core.abbrev, CoopApp.core.name, CoopApp.core.providers.first.id)
      @saved_org.organization_core_option = OrganizationCoreOption.new
      flash[:normal] = @saved_org.name + ' Created'
    else
     flash[:error] = @saved_org.name + ' Created. But Setting & Options were not.  - Problem'
    end
    redirect_to :controller => "/site/site", :action => :static_organization, :organization_id => @saved_org
  end

  def update
    @organization = @current_organization
    @address = @organization.addresses.first || @organization.addresses.new
    flash[:notice] = nil
    if request.post?

      if @organization.update_attributes params[:organization]
        @address.organization = @organization

        if !@address.update_attributes params[:address]
          flash[:error] = @address.errors.full_messages.to_sentence
        else
          flash[:notice] = "Organization Information Updated:  ", @organization.name
        end
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
