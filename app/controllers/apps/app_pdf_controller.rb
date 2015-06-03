class Apps::AppPdfController < Site::ApplicationController

  helper :all # include all helpers, all the time  
  layout "app_reports", :except =>[:elt_other_school_cycles]

  before_filter :initialize_parameters
  
  def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end


  def elt_school_plan
    @provider = @provider.nil? ? @school:@provider
    respond_to do |format|
      format.pdf do
        render :pdf => "#{@app.abbrev}_Action_Plan",
               :template => "apps/app_pdf/elt_school_plan.pdf.erb",
               :margin => { :top => 20, :bottom => 20, :left => 10, :right => 10},
               :page_height => 11,
               :page_width => 8.5,
               :footer => {:font_name=> 'Garamond', :font_size => 9, :line => true},
               :layout => false
      end
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
    if params[:app_id]
      @app = CoopApp.find_by_id(params[:app_id]) rescue nil
    end
    if params[:elt_plan_id]
      @plan = EltPlan.find_by_public_id(params[:elt_plan_id]) rescue nil
    end
 end
 
end
