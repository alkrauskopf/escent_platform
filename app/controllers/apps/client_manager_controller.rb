class Apps::ClientManagerController < Site::ApplicationController

 helper :all # include all helpers, all the time  
 layout "cm", :except =>[:manage_staff, :manage_client]

 before_filter :clear_notification, :except =>[]
  
 def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end
  
  def index

    initialize_parameters
    CoopApp.cm.first.increment_views
  end

  def manage_staff
    initialize_parameters
  end

  def manage_client
    initialize_parameters
  end
  
  def add_delete_client
    initialize_parameters
    if @current_organization.clients.include?(@client)
      @current_organization.organization_clients.for_client(@client).destroy_all
    else
      @current_organization.clients << @client
    end
    render :partial => "/apps/client_manager/client_staff", :locals=>{:app=>@app} 
  end
  
  def add_delete_client_consultant
    initialize_parameters
    if @current_organization.consultants_for_client(@client).include?(@consultant)
      @current_organization.consultant_assignment(@client, @consultant).destroy_all
    else
      @current_organization.organization_clients.for_client(@client).first.consultants << @consultant
    end
    render :partial => "/apps/client_manager/manage_client", :locals=>{:client => @client, :app=>@app} 
  end
  
  def toggle_enable_client
    initialize_parameters
      client = @current_organization.organization_clients.for_client(@client).first rescue nil
      if client
        client.update_attributes(:is_active =>!client.is_active)
      end
    render :partial => "/apps/client_manager/manage_client", :locals=>{:client => @client, :app=>@app} 
  end
  
  def toggle_enable_solution
    initialize_parameters
      if @solution
        @solution.update_attributes(:is_available =>!@solution.is_available)
      end
    render :partial => "/apps/client_manager/manage_solutions", :locals=>{ :app=>@app} 
  end
  
  def initialize_parameters 
    if  params[:organization_id]
      @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    end
    if params[:client_id]
      @client = Organization.find_by_public_id(params[:client_id])rescue nil
      unless @client
        @client = Organization.find_by_id(params[:client_id])rescue nil 
      end
    end
    if params[:consultant_id]
      @consultant = User.find_by_public_id(params[:consultant_id])rescue nil
      unless @consultant
        @consultant = User.find_by_id(params[:consultant_id])rescue nil 
      end
    end
    if params[:tool_id]
      @tool = CoopApp.find_by_id(params[:tool_id]) rescue nil
    end
    if params[:app_id]
      @app = CoopApp.find_by_id(params[:app_id]) rescue nil
    end
    unless @app
      @app = CoopApp.cm.first 
    end
    if params[:solution]
      @solution = CoopApp.find_by_public_id(params[:solution]) rescue nil
    end
    @admin = @current_user.cm_admin?(@current_organization)  
  end

  def refresh_client
    if params[:client_id]
      @client = Organization.find_by_public_id(params[:client_id])rescue nil
      unless @client
        @client = Organization.find_by_id(params[:client_id])rescue nil 
      end
    end    
  end

  def refresh_current_organization
      @current_organization = Organization.find_by_id(@current_organization.id)rescue nil 
  end

end
