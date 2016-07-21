class Apps::AppPdfController < Site::ApplicationController
  
  require 'prawn'
  layout "app_reports", :except =>[:elt_other_school_cycles,:elt_case]

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

  def elt_casex
    if !@case.nil?
      case_name = @case.name
      @cycle_name = @case.elt_cycle ? @case.elt_cycle.name : 'Undefined Cycle'
      @framework_name = @case.framework.nil? ? 'Unknown Framework' : @case.framework.name
      @school = @case.organization ? @case.organization : nil
    else
      case_name = 'Case Not Found'
    end
    respond_to do |format|
      format.pdf do
        render :pdf => "#{case_name}",
               :template => "apps/app_pdf/elt_case.erb",
               :margin => { :top => 20, :bottom => 20, :left => 10, :right => 10},
               :page_height => 11,
               :page_width => 8.5,
               :footer => {:font_name=> 'Garamond', :font_size => 9, :line => true},
               :layout => false
      end
    end
  end

  def elt_case
    respond_to do |format|
      format.html
      format.pdf do
        # pdf = ReportPdf.new(@current_organization)
        # send_data pdf.render, filename: 'report.pdf', type: 'application/pdf'
        pdf = Prawn::Document.new
        pdf.text "Hello There"
       # pdf.image Organization.all.first.logo.url
        # start_new_page
        # pdf.text "now it is here:"
        send_data pdf.render, filename: "xample.pdf", type: 'application.pdf'
        # pdf.render_file('prawn.pdf')
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
    if  params[:elt_case_id]
      @case = EltCase.find_by_public_id(params[:elt_case_id]) rescue nil
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
