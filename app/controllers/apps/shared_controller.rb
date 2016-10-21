class Apps::SharedController < Site::ApplicationController

  helper :all # include all helpers, all the time  
  layout "survey", :except =>[:analyze_question, :admin_list_app_resources,:admin_app_resources, :show_app_resources, :question_history, :list_surveys, :list_surveys_others, :create_survey_question, :broadcast_app_survey, :take_survey, :show_video, :my_taken_surveys, :my_self_surveys, :my_broadcast_surveys, :show_results, :show_aggregated_results]
  
  before_filter :clear_notification, :except =>[]
  before_filter :initialize_parameters, :except =>[]
  
 def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end


  def index
    initialize_parameters

  end

  def my_surveys
  
  end

  def my_taken_surveys

  end

  def my_broadcast_surveys

  end

  def my_self_surveys

  end

  def show_video

  end
  
  def show_app_resources
    @active_pool = app_resources
  end

  def admin_app_resources
    @active_pool = app_resources
    @resource_pool = (@current_user.resource_pool_for_org_app(@current_organization,@app) - @active_pool).uniq
  end

   def add_remove_resource
     new_position = params[:position].to_i 
    if params[:resource_id]
      @resource = Content.find_by_public_id(params[:resource_id]) rescue nil
    end
    if @resource && params[:function] == "add" && @current_organization.coop_app_resources.for_app(@app).for_content(@resource).empty?
      new_resource = @current_organization.coop_app_resources.new
      new_resource.content_id = @resource.id
      new_resource.is_featured = false
      new_resource.position =  new_position > 0 ? new_position : 1 
      new_resource.coop_app_id = @app.id      
      if new_resource.save 
        new_resource.reposition(new_position, true)
      end
    end
    if @resource && params[:function] == "remove"
      @current_organization.coop_app_resources.for_app(@app).for_content(@resource).destroy_all
      @current_organization.coop_app_resources.for_app(@app).by_position.each_with_index do |rsrc, idx|
        rsrc.update_attributes(:position=> idx+1)
      end
    end
    if @resource && params[:function] == "repo" && new_position > 0 
      existing_resource = @current_organization.coop_app_resources.for_app(@app).for_content(@resource).first rescue nil
      if existing_resource
        existing_resource.reposition(new_position, false)
      end
    end
 
    @active_pool = app_resources
    @resource_pool = (@current_user.resource_pool_for_org_app(@current_organization,@app) - @active_pool).uniq 
    
    render :partial => "/apps/shared/admin_app_resources", :locals => {:admin => @admin, :app => @app, :resource_pool => @resource_pool, :active_pool => @active_pool} 
   end 


  def broadcast_app_survey
    @survey = @app.survey_schedules.for_organization(@current_organization).for_audience(@instruction.tlt_survey_audience).for_type(@instruction.tlt_survey_type).active.first rescue nil
    @notify = @instruction.is_notify
    @anon = @instruction.is_anon
  end

  def app_survey_activate
    initialize_parameters 
    if params[:is_notify] == ''
      notify = @instruction.is_notify
    else
      notify = params[:is_notify] == '1' ? true: false
    end
    if params[:is_anon] == ''
      anon = @instruction.is_anon
    else
      anon = params[:is_anon] == '1' ? true: false
    end
    schedule_survey_app(@app, @current_organization, nil, @instruction.tlt_survey_audience, @instruction.tlt_survey_type, nil, params[:duration], notify, anon)
    survey = @instruction.scheduled_survey_for_org(@current_organization)
    @notify = survey.nil? ? @instruction.is_notify : survey.is_notify
    @anon = survey.nil? ? @instruction.is_anon: survey.is_anon
    render :partial => "broadcast_app_survey", :locals=> {:admin=> @admin, :app => @app, :instruction=> @instruction, :survey => survey, :notify => @notify, :anon => @anon}
  end

  def app_survey_deactivate
    initialize_parameters 
    @instruction = @schedule.survey_instruction
    @schedule.de_activate
    render :partial => "broadcast_app_survey", :locals=> {:admin=> @admin, :app => @app, :instruction=> @instruction, :survey => @instruction.scheduled_survey_for_org(@current_organization), :notify => @instruction.is_notify, :anon => @instruction.is_anon}
  end

  def submit_survey
 
  end


 def take_survey
   if params[:function] == "Submit"
     store_survey_responses_app(@schedule)
     redirect_to my_survey_view_path(:organization_id => @current_organization)
   end
  
  get_survey_headings(@schedule)

 end

 def add_survey_question
    initialize_parameters

    unless params[:question].empty? || @instruction.nil?
      @question = TltSurveyQuestion.new
      @question.organization_id = @current_organization.id
      @question.user_id = @current_user.id
      @question.tlt_survey_audience_id = @instruction.tlt_survey_audience.id
      @question.tlt_survey_type_id = @instruction.tlt_survey_type.id
      @question.question = params[:question]
      @question.tlt_survey_range_type_id = params[:range_type_id].empty? ? 1 : params[:range_type_id]   
      @question.is_active = true
      @question.coop_app_id = @app.id
      @question.position = params[:position].to_i ? params[:position].to_i : 1 
      @question.save
    end
   render :partial => "/apps/shared/list_surveys", :locals => {:admin => @admin, :instruction => @instruction, :app => @app} 
 end

 def analyze_question

  @start_date = @survey_question.tlt_survey_responses.sort_by{|s| s.created_at}.first.created_at rescue Date.today
  @end_date = @survey_question.tlt_survey_responses.sort_by{|s| s.created_at}.last.created_at rescue Date.today

 end
 
  def question_history

  @start_date = @survey_question.tlt_survey_responses.sort_by{|s| s.created_at}.first.created_at rescue Date.today
  @end_date = @survey_question.tlt_survey_responses.sort_by{|s| s.created_at}.last.created_at rescue Date.today

 end
 
 
 def analyze_dates

  @start_date = @survey_question.tlt_survey_responses.sort_by{|s| s.created_at}.first.created_at rescue Date.today
  @end_date = @survey_question.tlt_survey_responses.sort_by{|s| s.created_at}.last.created_at rescue Date.today
  render :partial => "apps/shared/analyze_question", :locals => {:admin => @admin, :question => @survey_question,:app => @app, :start_date=>@start_date, :end_date=>@end_date}

 end 


 def show_results

  get_survey_headings(@schedule)

 end

 def show_aggregated_results
    get_survey_headings(@schedule)
 end

 def create_survey_question

 end
 
 def list_surveys

 end

 def list_surveys_others

 end

 def toggle_survey
    if @survey_question
      @survey_question.update_attributes(:is_active =>!@survey_question.is_active)
    end
  render :partial => "apps/shared/list_surveys", :locals => {:admin => @admin, :instruction=>@instruction, :app => @app}
 end

 def position_survey
    if @survey_question
      @survey_question.update_attributes(:position => params[:position].to_i, :question => params[:question], :tlt_survey_range_type_id => params[:range_type_id].empty? ? @survey_question.tlt_survey_range_type_id : params[:range_type_id]  )
    end
  render :partial => "apps/shared/list_surveys", :locals => {:admin => @admin, :instruction=>@instruction, :app => @app}
 end


 def copy_survey
    if @survey_question
      @question = TltSurveyQuestion.new
      @question = @survey_question.clone
      @question.organization_id = @current_organization.id
      @question.user_id = @current_user.id
      @question.save
    end
   render :partial => "/apps/shared/list_surveys", :locals => {:admin => @admin, :instruction => @instruction, :app => @app} 
 end

 def destroy_survey_question
    if @survey_question
      @survey_question.destroy
    end
  render :partial => "apps/shared/list_surveys", :locals => {:admin => @admin, :instruction=>@instruction, :app => @app}
 end

 def create_folder
    unless !@app
      unless @folder.nil?
        parent_id = params[:parent_id] == "" ? @folder.parent_id : (params[:parent_id].to_i == @folder.id ? nil : (Folder.find_by_id(params[:parent_id]) ? params[:parent_id].to_i : nil))
        if @folder.update_attributes(:name=>params[:name], :description=>params[:description], :parent_id=> parent_id)
          flash[:notice] = @folder.name + ' Updated'
        else 
         flash[:error] = @folder.errors.full_messages       
        end 
      else
        folder = Folder.new
        folder.coop_app_id = @app.id
        folder.name = params[:name]
        folder.description = params[:description]
        folder.organization_id = @current_organization.id
        folder.parent_id = Folder.find_by_id(params[:parent_id]) ? params[:parent_id].to_i : nil
        if folder.save
          flash[:notice] =folder.name + ' Created'
        else 
         flash[:error] = folder.errors.full_messages       
        end 
      end
    end
  render :partial => "/apps/shared/manage_app_folders", :locals => {:admin => true, :app => @app, :folder=>nil}
 end

 def edit_folder
  render :partial => "/apps/shared/manage_app_folders", :locals => {:admin => true, :app => @app, :folder=>@folder}
 end

 def assign_offering_folder
  if @folder && @entity
    unless @folder.includes_entity?(@entity)
      unfolder_entity(@entity)     
      if @folder.empty_of_class?(@entity) || @current_organization.position_for_folder(@folder) == 0
        create_folder_position(@folder, @current_organization)     
      end 
      folderable = FolderFolderable.new
      folderable.folder_id = @folder.id
      folderable.position = 1
      @entity.folder_folderable = folderable  
    else
      unfolder_entity(@entity)
    end
  end
  render :partial => "/apps/classroom/offering_folders", :locals => {:admin => true, :app => @app}
 end

  def assign_folder_position
    if @folder && !@folder.position_for_scope(params[:scope_id].to_i, params[:scope_type]).nil?
      @folder.position_for_scope(params[:scope_id].to_i, params[:scope_type]).update_attributes(:position => params[:position].to_i)
    end
  render :partial => "/apps/classroom/offering_folders", :locals => {:admin => true, :app => @app}
  end

 def destroy_folder
   if @folder.destroy
     flash[:notice] = 'Folder Destroyed'
   else 
     flash[:error] = @folder.errors.full_messages       
   end
  render :partial => "/apps/shared/manage_app_folders", :locals => {:admin => true, :app => @app, :folder=>nil}
 end

  def assign_lu_folder
    if @folder && @topic 
      @folder.position_for_scope(@topic.id, @topic.class.to_s).nil? ? create_folder_position(@folder, @topic) : remove_folder_position(@folder, @topic)
    end
  render :partial => "/apps/classroom/offering_folder_setup", :locals => {:admin => true, :app=> @app, :lu=> @topic}
  end

  def assign_lu_folder_position
    if @folder && @topic
      @folder.position_for_scope(@topic.id, @topic.class.to_s).update_attributes(:position => params[:position].to_i)
    end
    render :partial => "/apps/classroom/offering_folder_setup", :locals => {:admin => true, :app=> @app, :lu=> @topic}
  end

  def assign_lu_folder_toggle_show
    if @folder && @topic
      folder = @folder.position_for_scope(@topic.id, @topic.class.to_s)
      folder.update_attributes(:is_hidden => !folder.is_hidden)
    end
    render :partial => "/apps/classroom/offering_folder_setup", :locals => {:admin => true, :app=> @app, :lu=> @topic}
  end
  
  def maintain_rubric
    if params[:scope_type] == 'EltType'
      @entity = EltType.find_by_id(params[:scope_id])
    elsif params[:scope_type] == 'EltElement'
      @entity = EltElement.find_by_id(params[:scope_id])
    elsif params[:scope_type] == 'EltPlanType'
      @entity = EltPlanType.find_by_id(params[:scope_id])
    elsif params[:scope_type] == 'EltStandard'
      @entity = EltStandard.find_by_id(params[:scope_id])
    else
      @entity = nil
    end
    @function = params[:function]
    if @function == 'New' && params[:commit]
      @rubric = Rubric.new(params[:rubric])
      unless @entity.rubrics.active.size > 4 && params[:rubric][:is_active] == '1'
        if @entity.rubrics << @rubric
          flash[:notice] = 'Rubric Created.Create Another'
        else
          flash[:error] = @rubric.errors.full_messages.to_sentence
        end 
      else
        flash[:error] = 'Maximum Number Of ACTIVE Rubrics Reached.'
      end
    elsif @function == 'Update'
      @rubric = Rubric.find_by_public_id(params[:rubric_id]) rescue nil      
      unless @rubric.nil? || !params[:commit]
        if @rubric.update_attributes(params[:rubric])
          flash[:notice] = 'Successfully Updated.   CLOSE WINDOW'
        else
          flash[:error] = @rubric.errors.full_messages.to_sentence
        end
      end
    elsif @function == 'Destroy' && params[:commit]
      @rubric = Rubric.find_by_public_id(params[:rubric_id]) rescue nil
      unless @rubric.nil?  
          if @rubric.destroy
            flash[:notice] = 'Rubric Destoyed.   CLOSE WINDOW'
            @function = 'New'
            @rubric = Rubric.new
          else
            flash[:error] = @rubric.errors.full_messages.to_sentence
          end
      else
        @function = 'New'
        @rubric = Rubric.new
      end       
    else
      @function = 'New'
      @rubric = Rubric.new
    end
  end


 
   private
   
    def initialize_parameters 
      @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil


      if params[:admin]
        @admin =  true
      end
      
      if params[:app_id]
        @app = CoopApp.find_by_id(params[:app_id]) rescue nil
      end
      unless @app
        @app = CoopApp.find_by_public_id(params[:app_id]) rescue nil
      end
  
      if params[:teacher_id]
        @teacher = User.find_by_public_id(params[:teacher_id]) rescue nil
      end

      @group = params[:group] ? params[:group] : "n"


      if params[:plan_id]
        @plan = UserDlePlan.find_by_public_id(params[:plan_id]) 
      end

      if params[:metric_id]
        @metric = DleMetric.find_by_id(params[:metric_id]) 
      end
      if params[:audience_id]
        @audience = TltSurveyAudience.find_by_public_id(params[:audience_id]) rescue nil
        unless @audience
        @audience = TltSurveyAudience.find_by_id(params[:audience_id]) rescue nil        
        end
      end      
      if params[:survey_type]
        @survey_type = TltSurveyType.find_by_public_id(params[:survey_type]) rescue nil
      end
      if params[:survey_type_id]
        @survey_type = TltSurveyType.find_by_id(params[:survey_type_id]) rescue nil
      end  
      if params[:schedule_id]
        @schedule = SurveySchedule.find_by_public_id(params[:schedule_id]) rescue nil
      else 
        @schedule = nil
      end
      if params[:survey_instruction]
        @instruction = SurveyInstruction.find_by_public_id(params[:survey_instruction]) rescue nil
      end
      if params[:survey_question_id]
        @survey_question = TltSurveyQuestion.find_by_public_id(params[:survey_question_id]) rescue nil
      end
      if params[:tlt_session_id]
        @entity = TltSession.find_by_public_id(params[:tlt_session_id]) rescue nil
      end    
      if params[:plan_id]
        @entity = UserDlePlan.find_by_public_id(params[:plan_id]) 
      end
      if params[:classroom_id]
        @entity =Classroom.find_by_public_id(params[:classroom_id])  rescue nil
      end
      if params[:topic_id]
        @topic =Topic.find_by_public_id(params[:topic_id])  rescue nil
      end
      if params[:offering_id]
        @entity =Classroom.find_by_id(params[:offering_id])  rescue nil
      end
       if params[:diagnostic_id]
        @entity =TltDiagnostic.find_by_public_id(params[:classroom_id])  rescue nil
      end   
      if params[:folder_id]
        @folder = Folder.find_by_public_id(params[:folder_id]) rescue nil
      end
    end


  def get_survey_headings(schedule)
    if schedule.entity.class == ClassroomPeriod.first.class 
      @offering = schedule.entity.classroom
      @teacher = schedule.user
      @observer = nil
    end
    if schedule.entity.class == TltSession.first.class  
      @offering = schedule.entity.classroom
      @teacher = schedule.entity.user
      @observer = schedule.entity.tracker
    end
    if schedule.entity.class == UserDlePlan.first.class 
      @offering = nil
      @teacher = schedule.entity.user
      @observer = nil
     end
    if schedule.entity.class == TltDiagnostic.first.class 
      @offering = nil
      @teacher = schedule.entity.user
      @observer = nil
     end
    if schedule.entity.class == EltCycle.first.class 
      @offering = nil
      @teacher = nil
      @observer = nil
     end
  end

  def app_resources
    @current_organization.coop_app_resources.for_app(@app).by_position.collect{|ar| ar.content}.uniq    
  end

  def unfolder_entity(entity)
    if entity.folder_folderable
      if entity.folder_folderable.folder.class_contents(entity).size == 1
        remove_folder_position(entity.folder_folderable.folder, @current_organization)
      end
      entity.folder_folderable.destroy
    end  
  end

  def create_folder_position(folder, scope)
    if scope.folder_positions.for_folder(folder).empty?
      folder_pos= FolderPosition.new
      folder_pos.scope_id = scope.id
      folder_pos.scope_type = scope.class.to_s
      folder_pos.position = scope.folder_positions.all.empty? ? 1 : scope.folder_positions.all.last.position + 1
      folder.folder_positions << folder_pos
    end
  end

  def remove_folder_position(folder, scope)
   scope.folder_positions.for_folder(folder).destroy_all
  end
  
end
