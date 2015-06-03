class Apps::StaffDevelopController < Site::ApplicationController
  helper :all # include all helpers, all the time  
 layout "staff_develop", :except =>[:cycle_update, :take_survey, :show_app_post, :coaching_update, :stage_display, :option_stages, :option_metrics, :coach_assignments]

  
  before_filter :clear_notification, :except =>[]
  before_filter :initialize_parameters, :except =>[]
  
 def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end



  def index
    CoopApp.pd.first.increment_views
    if @teacher.user_dle_plans.empty?
      @package = []
    else
      @package = @teacher.dle_plan_active? ? @teacher.current_dle_plan.package : @teacher.user_dle_plans.last.package
    end
  end

  def start_plan
    
    if @teacher.user_dle_plans.empty?
      plan_num = 1
    else
      plan_num = @teacher.user_dle_plans.by_plan_number.last.plan.nil? ? 1 :  @teacher.user_dle_plans.by_plan_number.last.plan + 1
    end   
    new_plan = UserDlePlan.new
    new_plan.dle_cycle_id = DleCycle.all_by_stage.first.id
    new_plan.cycle_start_date = Date.today
    new_plan.is_current = true
    new_plan.plan = plan_num
    @teacher.user_dle_plans << new_plan            
    @teacher = User.find_by_public_id(params[:teacher_id]) rescue nil

    unless @current_organization.dle_cycle_orgs.for_dle_cycle(DleCycle.stage_one.first).first.tlt_survey_type_id == nil
      audience = @app.tlt_survey_audiences.teacher.first
      type = @current_organization.dle_cycle_orgs.for_dle_cycle(DleCycle.stage_one.first).first.tlt_survey_type
      schedule_survey_app(@teacher.user_dle_plans.last, @current_organization, nil, audience, type, nil, nil, type.notify_default(audience), type.anon_default(audience))
    end
    redirect_to :action => :index, :organization_id => @current_organization, :teacher_id => @teacher
  end

  def close_cycle

    get_actuals = @plan.preferences(@current_organization).is_actual
    if get_actuals && !@plan.plan_with_targets.nil?
      @plan.plan_with_targets.user_dle_plan_metrics.each do|user_met|
        unless @plan == @plan.plan_with_targets
          new_plan = UserDlePlanMetric.new
          new_plan.dle_metric_id = user_met.dle_metric_id 
          new_plan.target = user_met.target
          new_plan.actual = @plan.user.dle_stat_for(user_met.dle_metric)
          new_plan.note = user_met.note
          @plan.user_dle_plan_metrics<<new_plan      
        else
          user_met.update_attributes(:actual=> @plan.user.dle_stat_for(user_met.dle_metric))
        end
      end  
    end
    @plan.update_attributes(:date_finalized=> Date.today)
    @plan.survey_schedules.each do|s| s.de_activate end
    if @plan.dle_cycle == DleCycle.all_by_stage.last
      @plan.user.close_current_plans
    else
      @plan.new_stage  
      @plan = UserDlePlan.find_by_public_id(params[:plan_id]) 
      next_cycle = @plan.user.user_dle_plans.last.dle_cycle
      audience = @app.tlt_survey_audiences.teacher.first rescue nil
      type = @current_organization.dle_cycle_orgs.for_dle_cycle(next_cycle).first.tlt_survey_type rescue nil
      notify = type.nil? ? nil : type.notify_default(audience)
      anon = type.nil? ? nil : type.anon_default(audience)
      schedule_survey_app(@plan.user.user_dle_plans.last, @current_organization, nil, audience, type, nil, nil, notify, anon)
    end
    redirect_to :action => :index, :organization_id => @current_organization, :teacher_id => @plan.user
   end

  def metric_for_organization

    if @current_organization.organization_dle_metrics.for_metric(@metric).size > 0
      @current_organization.organization_dle_metrics.for_metric(@metric).destroy_all
    else
      new_metric = OrganizationDleMetric.new
      new_metric.dle_metric_id = @metric.id
      new_metric.note = params[:metric_note]     
      @current_organization.organization_dle_metrics << new_metric
    end

     render :partial => "/apps/staff_develop/option_metrics", :locals => {:admin => @admin, :app => @app} 
  end

  def cycle_update

  end
  
  def stage_display

  end
 
  def option_metrics
  end

  def coach_assignments

  end

  def update_coach_assignment

    if @coach.coachees.include?(@teacher)
        @coach.coachees.delete @teacher
    else
        @coach.coachees<<@teacher
    end
      render :partial => "/apps/staff_develop/coach_selections", :locals => {:coach => @coach}     
  end

  def show_app_post
    @blog_post = BlogPost.find_by_public_id(params[:blog_post_id]) rescue nil
    @size = params[:size]
  end


  def select_coach
   render :partial => "/apps/staff_develop/coach_assignments", :locals => {:admin => @admin, :app => @app, :coach => @coach} 
  end


  def toggle_coach_enable
    if  @current_organization.dle_org_option
      @current_organization.dle_org_option.update_attributes(:is_coach_enabled =>!@current_organization.dle_org_option.is_coach_enabled)
    else
      @current_organization.dle_set_org_options
    end
     render :partial => "/apps/staff_develop/coach_assignments", :locals => {:admin => @admin, :app => @app, :coach => nil}    
  end
  
  def option_stages
    DleCycle.all_by_stage.each do |stage|
      unless @current_organization.dle_cycle_orgs.collect{|c| c.dle_cycle_id}.include?(stage.id)
        create_org_stage_preference(stage)
      end
    end
  end
 
  def edit_org_stage_preferences
    unless @stage.nil?
      pref = @current_organization.dle_cycle_orgs.for_dle_cycle(@stage).first rescue nil 
      unless pref.nil?
        if params[:toggle_output]
          pref.update_attributes(:is_output => !pref.is_output)
        end
        if params[:output_label]
          pref.update_attributes(:output_label => params[:output_label])
        end
        if params[:toggle_attach]
          pref.update_attributes(:is_attachable => !pref.is_attachable)
        end
        if params[:attach_label]
          pref.update_attributes(:attach_label => params[:attach_label])
        end
        if params[:toggle_targets]
          pref.update_attributes(:is_targets => !pref.is_targets)
        end
        if params[:toggle_actual]
          pref.update_attributes(:is_actual => !pref.is_actual)
        end
         if params[:survey_type_id]
          
          pref.update_attributes(:tlt_survey_type_id => params[:survey_type_id] == "0" ? nil : params[:survey_type_id])
        end
       end
     end
    render :partial => "apps/staff_develop/option_stages", :locals => {:admin => @admin, :stage => @stage,:app => @app}
  end
  
  def edit_cycle

    if params[:output_note]
      @plan.update_attributes(:output_notes=> params[:output_note])
    end
     render :partial => "/apps/staff_develop/cycle_update" 
  end


  def coaching_update

  end

  def add_coaching

    if @teacher && !params[:coaching].empty?
        coaching= @teacher.current_dle_plan.user_dle_plan_coachings.new
        coaching.user_id = @current_user.id
        coaching.comment =  params[:coaching]
        coaching.save
    end
     render :partial => "/apps/staff_develop/coaching_comments", :locals => {:app => @app, :teacher => @teacher, :plan => @teacher.current_dle_plan}
  end


  def edit_target
    if @plan.user_dle_plan_metrics.for_metric(@metric).first
      @plan.user_dle_plan_metrics.for_metric(@metric).first.update_attributes(:target => params[:target], :actual => params[:actual], :note => params[:note])
    else
      unless @metric.nil?
        new_plan = UserDlePlanMetric.new
        new_plan.dle_metric_id = @metric.id  
        new_plan.target = params[:target]
        new_plan.actual = params[:actual]
        new_plan.note = params[:note]
        @plan.user_dle_plan_metrics<<new_plan
      end
    end
     render :partial => "/apps/staff_develop/targets_update" 
  end

 def submit_attachment
    return if request.get?
     if @current_user == @teacher
        if params[:commit]== "Remove"
          @plan.update_attributes(:attach_file_name => nil, :attach_file_size => nil, :attach_content_type => nil, :attach_date => nil)
        else
          @plan.attributes = params[:user_dle_plan]
          @plan.attach_date = Date.today
          if @plan.save
             flash[:notice] = "update success"
          end
        end
     end
    redirect_to :action => :index, :organization_id => @current_organization, :teacher_id => @plan.user
  end

  def take_survey
    initialize_parameters        
    if params[:function] == "submit"
      if @plan.tlt_survey_responses.empty?
        store_survey_responses_app(@schedule)
        redirect_to :action => 'index', :organization_id => @current_organization, :teacher_id => @teacher
      end # end of Check if Survey Already Taken
    end
  end


 def add_remove_resource
   new_position = params[:position].to_i 
   if @resource
      existing_resource = @resource.dle_resources.for_org(@current_organization).first rescue nil
      if existing_resource
        if params[:function] == "delete"
          existing_resource.destroy
          @current_organization.dle_resources.by_position.each_with_index do |rsrc, idx|
            rsrc.update_attributes(:position=> idx+1)
          end
        elsif params[:function] == "repo" && new_position > 0 
          existing_resource.reposition(new_position, false)
        end
      else
        new_resource = @current_organization.dle_resources.new
        new_resource.content_id = @resource.id
        new_resource.is_featured = false
        new_resource.position =  new_position > 0 ? new_position : 1 
        if new_resource.save 
          new_resource.reposition(new_position, true)
        end
      end
   end
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   render :partial => "/apps/staff_develop/manage_resources", :locals => {:admin => @admin, :app => @app} 
 end 



   private
   
    def initialize_parameters 
      @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil

      if params[:app_id]
        @app = CoopApp.find_by_id(params[:app_id]) rescue nil
      end
      unless @app
        @app = CoopApp.pd.first
      end
  
      if params[:teacher_id]
        @teacher = User.find_by_public_id(params[:teacher_id]) rescue nil
      end
  
      if params[:coach_id]
        @coach = User.find_by_id(params[:coach_id]) rescue nil
      end
      
      if @teacher
        @current_cycle = @teacher.user_dle_plans.still_open.sort_by{|p| p.dle_cycle.stage}.first.dle_cycle rescue DleCycle.for_stage(1).first
      end
      if params[:plan_id]
        @plan = UserDlePlan.find_by_public_id(params[:plan_id]) 
      end

      if params[:metric_id]
        @metric = DleMetric.find_by_id(params[:metric_id]) 
      end

      if params[:resource_id]
        @resource = Content.find_by_public_id(params[:resource_id]) 
      end
      
      if params[:cycle_id]
        @stage = DleCycle.find_by_id(params[:cycle_id]) rescue nil
      end

      if params[:schedule_id]
        @schedule = SurveySchedule.find_by_public_id(params[:schedule_id]) rescue nil
      end    

      unless @current_organization.dle_org_option
        @current_organization.dle_set_org_options
      end
    
    @admin = @current_user.has_authorization_level_for?(@current_organization, "pd_administrator")  

    end
    
  def schedule_pd_survey(plan_cycle, audience, type)
    schedule = plan_cycle.survey_schedules.new
    schedule.organization_id = @current_organization.id
    schedule.subject_area_id = nil
    schedule.schedule_start = Date.today
    schedule.user_id = plan_cycle.user_id
    if audience == "teacher"
      schedule.tlt_survey_audience_id = @app.tlt_survey_audiences.teacher.first.id rescue nil
    end    
    schedule.tlt_survey_type_id = type.id 
    unless schedule.tlt_survey_audience_id.nil? || schedule.tlt_survey_type_id.nil?
      schedule.save
    end
  end

  def create_org_stage_preference(s)
    stage_pref = @current_organization.dle_cycle_orgs.new
    stage_pref.dle_cycle_id = s.id
    stage_pref.tlt_survey_type_id = s.tlt_survey_type_id
    stage_pref.is_output = s.is_output
    stage_pref.output_label = s.output_label
    stage_pref.is_targets = s.is_targets
    stage_pref.is_actual = s.is_actual
    stage_pref.is_attachable = s.is_attachable
    stage_pref.attach_label = s.attach_label
    stage_pref.save   
  end

end
