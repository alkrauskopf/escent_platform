class Apps::SchoolTimeController < ApplicationController

 helper :all # include all helpers, all the time  
 layout "stat", :except =>[:options_baselines, :ista_dashboard, :ista_case_show]

 before_filter :current_organization, :except => []
 before_filter :current_user, :except => []
 before_filter :stat_allowed?, :except=>[]
 before_filter :current_user_app_authorized?, :except=>[]
 before_filter :clear_notification, :except =>[]
 before_filter :increment_app_views, :only=>[:index]
  
 def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end
  
  def index
    initialize_parameters
  end

 def start_ista_case
    initialize_parameters
  unless @step
    @step = IstaStep.step_1.first
  end
 end

 def maintain_ista_case
    initialize_parameters 
  unless @step
    @step = IstaStep.step_1.first
  end
  if params[:function] == "New"
    new_case = IstaCase.new
    new_case.user_id = @current_user.id
    new_case.organization_id = @current_organization.id
    new_case.ista_step_id = IstaStep.step_2.first.id
    new_case.title = params[:ista_case][:title]
    new_case.case_students = params[:ista_case][:case_students]
    new_case.case_teachers = params[:ista_case][:case_teachers]
    new_case.daysweek = @current_organization.time_allocation.weekday_std
    new_case.hrsday_std = @current_organization.time_allocation.hrsday_std
    new_case.daysyear_std = @current_organization.time_allocation.daysyear_std
    new_case.hrsday_er = @current_organization.time_allocation.hrsday_er
    new_case.daysyear_er = @current_organization.time_allocation.daysyear_er
    new_case.hrsday_ls = @current_organization.time_allocation.hrsday_ls
    new_case.daysyear_ls = @current_organization.time_allocation.daysyear_ls
    new_case.is_active = true
    if new_case.save
      flash[:notice] = "Case Saved" 
      @ista_case = @current_organization.ista_cases.last
      create_activity_allocations(@ista_case, IstaStep.step_2.first)
    else
      flash[:error] = new_case.errors.full_messages.to_sentence
    end
  elsif params[:function] == "Update" && @ista_case
    if @ista_case.update_attributes(params[:ista_case])
       flash[:notice] = "Step 1 Updated" 
    else
      flash[:error] = @ista_case.errors.full_messages.to_sentence
    end  
  end
 end 

 def options_baselines
    initialize_parameters
 end

 def ista_dashboard
    initialize_parameters
    @school = @current_organization
 end

 def ista_case_show
    initialize_parameters
 end

 def maintain_baselines
    initialize_parameters
    if @current_organization.time_allocation
      baselines = @current_organization.time_allocation
      label = "Updated"
    else
      baselines = TimeAllocation.new
      baselines.organization_id = @current_organization.id      
      label = "Created"
    end

      baselines.hrsday_std = params[:hrsday_std].to_f 
      baselines.weekday_std = params[:weekday_std].to_f
      baselines.daysyear_std = params[:daysyear_std].to_f
      baselines.hrsday_er = params[:hrsday_er].to_f
      baselines.daysyear_er = params[:daysyear_er].to_f
      baselines.hrsday_ls = params[:hrsday_ls].to_f
      baselines.daysyear_ls = params[:daysyear_ls].to_f
      baselines.fte_teacher = params[:fte_teacher].to_f
      baselines.fte_admin = params[:fte_admin].to_f
      baselines.total_students = params[:total_students].to_i
      
      if baselines.save
        flash[:notice] = "Allocated " + @current_organization.short_name + " Time Baselines " + label
      else
        flash[:error] = baselines.errors.full_messages.to_sentence
      end
      refresh_organization
    render :partial => "/apps/school_time/manage_options_baselines", :locals=>{:app=>@app}   
 end 

 def step_2_update
    initialize_parameters

    @ista_case.ista_case_allocations.each do |alloc|
      update=false
      if params[alloc.id.to_s]
        if alloc.update_attributes(:minsweek=>params[alloc.id.to_s][:mins].to_i)                       
          update=true      
        end
      end
    end
    redirect_to stat_case_path(:organization_id => @current_organization, :case_id =>@ista_case, :function=>'Pass')
 end

 def step_update_mins
    initialize_parameters

    @ista_case.ista_case_allocations.each do |alloc|
      update=false
      if params[alloc.id.to_s]
        if alloc.update_attributes(:minsweek=>params[alloc.id.to_s][:mins].to_i)                       
          update=true      
        end
      end
    end
    redirect_to stat_case_path(:organization_id => @current_organization,:case_id =>@ista_case, :function=>'Pass')
 end
 
 def step_update_hours
    initialize_parameters

    @ista_case.ista_case_allocations.each do |alloc|
      update=false
      if params[alloc.id.to_s]
        if alloc.update_attributes(:hrsyear=>params[alloc.id.to_s][:yrs].to_i)                       
          update=true      
        end
      end
    end
    redirect_to stat_case_path(:organization_id => @current_organization, :case_id =>@ista_case, :function=>'Pass')
 end

 def finish_step
    initialize_parameters
        if @ista_case && @ista_case.ista_step
            unless IstaStep.next_step(@ista_case.ista_step).empty?
              next_step = IstaStep.next_step(@ista_case.ista_step).first
              if @ista_case.update_attributes(:ista_step_id=> next_step.id)                           
                create_activity_allocations(@ista_case, next_step)            
              end
            end
        end
    redirect_to stat_case_path(:organization_id => @current_organization, :case_id =>@ista_case, :function=>'Pass')
 end

 def finalize_case
    initialize_parameters
    @ista_case.update_attributes(:is_final=>true, :final_date=>Date.today)
    redirect_to self.send(CoopApp.stat.link_path, {:organization_id => @current_organization})
 end 


 def select_school_dashboard
    initialize_parameters
    render :partial => "/apps/school_time/school_ista_dashboard", :locals => {:school => @school}
 end

 def destroy_case
    initialize_parameters
    if @ista_case
      @ista_case.destroy
    end
    render :partial => "/apps/school_time/list_cases", :locals=>{:app=>@app}
 end 

   private

 def stat_allowed?
   @current_application = CoopApp.stat
   @current_provider = @current_organization.app_provider(@current_application)
   current_app_enabled_for_current_org?
 end

  def initialize_parameters 
    if  params[:organization_id]
      @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    end
    if  params[:school_id]
      @school = Organization.find_by_id(params[:school_id])rescue nil
    end
    if params[:step_id]
      @step = IstaStep.find_by_public_id(params[:step_id]) rescue nil
    end
    
    @ista_case = params[:case_id] ? IstaCase.find_by_public_id(params[:case_id]): nil

    @admin = @current_user.stat_admin_for_org?(@current_organization)
  end

  def refresh_organization
      @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil    
  end

  def  create_activity_allocations(ista_case, step)
    IstaGroup.all.each do |grp|
      if grp.subject_list == "CORE"
        SubjectArea.core.each do |subj|
          case_alloc = IstaCaseAllocation.new
          case_alloc.activity_id = subj.id
          case_alloc.activity_type = subj.class.to_s
          case_alloc.ista_step_id = step.id
          case_alloc.ista_group_id = grp.id
          case_alloc.name = subj.name
          ista_case.ista_case_allocations << case_alloc      
        end
      elsif grp.subject_list == "NONCORE"
        SubjectArea.noncore.each do |subj|
          case_alloc = IstaCaseAllocation.new
          case_alloc.activity_id = subj.id
          case_alloc.activity_type = subj.class.to_s
          case_alloc.ista_step_id = step.id
          case_alloc.ista_group_id = grp.id
          case_alloc.name = subj.name
          ista_case.ista_case_allocations << case_alloc       
        end
      else
        grp.ista_activities.for_step(step).each do |subj|
          case_alloc = IstaCaseAllocation.new
          case_alloc.activity_id = subj.id
          case_alloc.activity_type = subj.class.to_s
          case_alloc.ista_step_id = step.id
          case_alloc.ista_group_id = grp.id
          case_alloc.name = subj.name
          ista_case.ista_case_allocations << case_alloc       
        end       
      end  
    end
  end
end
