class Apps::AppReportController < Site::ApplicationController

  helper :all # include all helpers, all the time  
  layout "app_reports", :except =>[:elt_other_school_cycles]

  before_filter :current_application, :except => []
  before_filter :current_user_app_authorized?, :except=>[]
  before_filter :clear_notification
  before_filter :initialize_parameters

  def index
  end

  def elt_school_diag
    @report = params[:report_id]
    @plan_type = EltPlanType.school
    @provider = @current_organization.app_provider(@current_application)
    @school =  @current_organization == @provider ? nil : @current_organization
    @cycle = @current_organization.elt_org_option.elt_cycle ? @current_organization.elt_org_option.elt_cycle : nil
    @activity = @cycle.nil? ? nil : @cycle.master_activity
    @activity = (!@school.nil? && !@activity.reportable?) ? nil : @activity 
  end

  def elt_select_school_for_diag
    @cycle = @school.elt_org_option.elt_cycle ? @school.elt_org_option.elt_cycle : nil
    @activity = @cycle.nil? ? nil : @cycle.master_activity
    render :partial => "/apps/app_report/elt_school_diag", :locals => {:provider => @provider, :app => @app, :school => @school, :cycle => @cycle, :activity => @activity}
  end

  def elt_select_school_for_sched
    @cycle = @school.elt_org_option.elt_cycle ? @school.elt_org_option.elt_cycle : nil
    render :partial => "/apps/app_report/elt_school_sched", :locals => {:provider => @provider, :app => @app, :school => @school, :cycle => @cycle}
  end

  def elt_select_cycle_for_sched
    render :partial => "/apps/app_report/elt_school_sched", :locals => {:provider => @provider, :app => @app, :school => @school, :cycle => @cycle}
  end

  def elt_select_activity_for_school
    @activity = @activity.nil? ? @cycle.master_activity : @activity
    render :partial => "/apps/app_report/elt_school_diag", :locals => {:provider => @provider, :app => @app, :school => @school, :cycle => @cycle, :activity => @activity}
  end 

  def elt_select_cycle_for_school
    @activity = @cycle.activities.include?(@activity) ? @activity : @cycle.master_activity
    render :partial => "/apps/app_report/elt_school_diag", :locals => {:provider => @provider, :app => @app, :school => @school, :cycle => @cycle, :activity => @activity}
  end 
  
  def elt_select_cycle_for_diag
    render :partial => "/apps/app_report/elt_cycle_diag", :locals => {:provider => @provider, :app => @app, :cycle => @cycle, :activity => @cycle.master_activity}
  end
  
  def elt_select_activity_for_cycle
    @activity = @activity.nil? ? @cycle.master_activity : @activity
    render :partial => "/apps/app_report/elt_cycle_diag", :locals => {:provider => @provider, :app => @app, :cycle => @cycle, :activity => @activity}
  end
  
  def elt_select_activity_for_network
    render :partial => "/apps/app_report/elt_network_diag", :locals => {:provider => @provider, :app => @app, :activity => @activity}
  end

  def elt_destroy_plan  
    @plan.destroy
    redirect_to elt_report_path(:organization_id => @current_organization, :user_id => @current_user, :report_id => "SD")
  end

  def elt_other_school_cycles  
      
  end

  def elt_export_network_excel
    unless @app
      @app = CoopApp.elt
    end    
    respond_to do |format|
      format.xls
    end 
  end

  
   private

 def initialize_parameters
    if  params[:organization_id]
      @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    end
    if  params[:user_id]
      @current_user = User.find_by_public_id(params[:user_id])rescue nil
    end
    if  params[:organization_type_id]
      @org_type = OrganizationType.find_by_id(params[:organization_type_id])
    end
    if  params[:elt_cycle_id]
      @cycle = EltCycle.find_by_public_id(params[:elt_cycle_id]) rescue nil
    end    
    if  params[:activity_id]
      @activity = EltType.find_by_public_id(params[:activity_id]) rescue nil
    end
    if  params[:indicator_id]
      @indicator = EltIndicator.find_by_public_id(params[:indicator_id]) rescue nil
    end
    if  params[:school_id]
      @school = Organization.find_by_public_id(params[:school_id])rescue nil
    end
    if  params[:provider_id]
      @provider = Organization.find_by_public_id(params[:provider_id])rescue nil
    end    

    if params[:elt_plan_id]
      @plan = EltPlan.find_by_public_id(params[:elt_plan_id]) rescue nil
    end
 end
end
