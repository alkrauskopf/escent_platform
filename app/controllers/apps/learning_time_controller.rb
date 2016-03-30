class Apps::LearningTimeController  < Site::ApplicationController
  
 helper :all  # include all helpers, all the time
 layout "elt", :except =>[:manage_frameworks, :manage_plan_types, :export_case, :report_school_diag, :report_community_diag,
                          :show_case_element_indicators, :transfer_plans, :transfer_cases,
                          :show_school_cycle_activity_cases, :list_school_cycle_activities, :list_case_evidences, :show_activity_cases,
                          :manage_cycles, :manage_activities, :manage_elements, :manage_indicators,
                          :view_latest_submitted, :show_case_summary, :case_indicators_element_rubric, :list_case_comments,
                          :show_activity_map, :show_evidence_map]

 before_filter :elt_allowed?, :except=>[]
 before_filter :current_user_app_authorized?, :except=>[]

 before_filter :clear_notification, :except =>[]
 before_filter :initialize_parameters, :except =>[]
  
 def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
 end
  
  def index
    initialize_parameters
    CoopApp.elt.increment_views
    if params[:function] && params[:function] == "New"
      new_case = EltCase.new
      new_case.user_id = @current_user.id
      new_case.organization_id = @current_organization.id
      new_case.user_name = @current_user.last_name_first
      if new_case.save
        redirect_to :action => :start_case, :elt_case_id => @current_user.elt_cases.last, :organization_id=>@current_organization, :app_id=>@app  
      end    
    end
  end

 def manage_frameworks
   initialize_parameters
 end

  def manage_cycles
    initialize_parameters
  end
    
  def manage_activities
    initialize_parameters
  end

  def manage_elements
    initialize_parameters
  end
    
  def manage_indicators
    initialize_parameters
    @framework = @current_organization.elt_framework
    @activities_for = @current_organization.elt_types.by_position
    @activities_from = []
  end
    
  def manage_plan_types
    initialize_parameters
  end
      
  def transfer_cases
    initialize_parameters
  end

 def transfer_plans
   initialize_parameters
 end

  def list_school_cycle_activities
    initialize_parameters
  end

  def maintain_element_x
    @task = params[:task]
    if @framework && params[:function] && params[:function] == "New"
      @element = EltElement.new(params[:elt_element])
      @element.is_active = false
      @element.organization_id = @current_organization.id
      @element.elt_framework_id = @framework.id
      @element.form_background = (params[:elt_element][:form_background].empty? ? "#FFFFFF" : params[:elt_element][:form_background]).upcase
      @element.i_form_background = (params[:elt_element][:i_form_background].empty? ? "#FFFFFF" : params[:elt_element][:i_form_background]).upcase
      @element.e_font_color = (params[:elt_element][:e_font_color].empty? ? "#000000" : params[:elt_element][:e_font_color]).upcase
      @element.abbrev = params[:elt_element][:abbrev].upcase
      @element.position = params[:elt_element][:position].to_i
      if @element.save
        flash[:notice] = "Successfully created element.   CLOSE WINDOW"
      else
        flash[:error] = @element.errors.full_messages.to_sentence
      end
    elsif params[:task] == "Update"
      @element = EltElement.find_by_public_id(params[:elt_element_id]) rescue nil
      unless @element.nil?
        if params[:function] && params[:function] == "Update"
          params[:elt_element][:form_background] = params[:elt_element][:form_background].upcase
          params[:elt_element][:i_form_background] = params[:elt_element][:i_form_background].upcase
          params[:elt_element][:e_font_color] = params[:elt_element][:e_font_color].upcase
          params[:elt_element][:abbrev] = params[:elt_element][:abbrev].upcase     
          if @element.update_attributes(params[:elt_element])
            flash[:notice] = "Successfully Updated.   CLOSE WINDOW"
          else
            flash[:error] = @element.errors.full_messages.to_sentence
          end        
        end
        if !@element.nil? && params[:function] && params[:function] == "Destroy"      
          if @element.destroy
            flash[:notice] = "Element Destroyed.   CLOSE WINDOW"
            @element = EltElement.new
            @task = "New"
          else
            flash[:error] = @element.errors.full_messages.to_sentence
          end        
        end
      else
        @element = EltElement.new
      end       
    else
      @element = EltElement.new
    end
  end 

  def maintain_cycle
    @task = params[:task]
    if @framework && params[:function] && params[:function] == "New"
      @cycle = EltCycle.new(params[:elt_cycle])
      @cycle.is_active = false
      @cycle.begin_date = Date.new(params[:begin_date]['(1i)'].to_i, params[:begin_date]['(2i)'].to_i, 1).beginning_of_month
      @cycle.end_date = Date.new(params[:end_date]['(1i)'].to_i, params[:end_date]['(2i)'].to_i, 1).end_of_month
      @cycle.elt_framework_id = @framework.id
      if @current_organization.elt_cycles << @cycle
        flash[:notice] = "Successfully created diagnostic cycle.   CLOSE WINDOW or CREATE ANOTHER"
        @cycle = EltCycle.new
      else
        flash[:error] = @cycle.errors.full_messages.to_sentence
      end
    elsif params[:task] == "Update"
      @cycle = EltCycle.find_by_public_id(params[:elt_cycle_id]) rescue nil
      unless @cycle.nil?
        if params[:function] && params[:function] == "Update"   
          @cycle.begin_date = Date.new(params[:begin_date][@cycle.id.to_s + '(1i)'].to_i, params[:begin_date][@cycle.id.to_s + '(2i)'].to_i, 1).beginning_of_month
          @cycle.end_date = Date.new(params[:end_date][@cycle.id.to_s + '(1i)'].to_i, params[:end_date][@cycle.id.to_s + '(2i)'].to_i, 1).end_of_month
          if @cycle.update_attributes(params[:elt_cycle])
            flash[:notice] = "Successfully Updated.   CLOSE WINDOW"
          else
            flash[:error] = @cycle.errors.full_messages.to_sentence
          end        
        end
        if !@cycle.nil? && params[:function] && params[:function] == "Delete"      
          if @cycle.update_attributes(:is_active=>false, :is_delete=>true)
            flash[:notice] = "Diagnostic Cycle Deleted.   CLOSE WINDOW"
            @cycle = EltCycle.new
            @task = "New"
          else
            flash[:error] = @cycle.errors.full_messages.to_sentence
          end        
        end
      else
        @cycle = EltCycle.new
      end       
    else
      @cycle = EltCycle.new
    end
  end 

  def maintain_activity
    @task = params[:task]
    if @framework && params[:function] && params[:function] == "New"
      @activity = EltType.new(params[:elt_type])
      @activity.is_active = false
      @activity.elt_framework_id = @framework.id
      if @current_organization.elt_types << @activity
        flash[:notice] = "Successfully created activity.   CLOSE WINDOW"
      else
        flash[:error] = @activity.errors.full_messages.to_sentence
      end
    elsif params[:task] == "Update"
      @activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
      unless @activity.nil?
        if params[:function] && params[:function] == "Update"   
          params[:elt_type][:elt_activity_type_id] = params[:elt_type][:elt_activity_type_id] == "" ? @activity.elt_activity_type_id : params[:elt_type][:elt_activity_type_id]
          if @activity.update_attributes(params[:elt_type])
            flash[:notice] = "Successfully Updated.   CLOSE WINDOW"
          else
            flash[:error] = @activity.errors.full_messages.to_sentence
          end        
        end
        if !@activity.nil? && params[:function] && params[:function] == "Destroy"      
          if @activity.destroy
            flash[:notice] = "Activity Destoyed.   CLOSE WINDOW"
            @activity = EltType.new
            @task = "New"
          else
            flash[:error] = @activity.errors.full_messages.to_sentence
          end        
        end
      else
        @activity = EltType.new
      end       
    else
      @activity = EltType.new
    end
  end 

  def maintain_indicator
    @task = params[:task]
    @activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
    @element = EltElement.find_by_public_id(params[:elt_element_id]) rescue nil
    if !@element.nil? && !@activity.nil? && params[:function] && params[:function] == "New"
      @indicator = EltIndicator.new(params[:elt_indicator])
      @indicator.elt_type_id = @activity.id
      @indicator.elt_element_id = @element.id
      @indicator.is_active = false
      if @indicator.save
        flash[:notice] = "Successfully created activity.   CLOSE WINDOW"
      else
        flash[:error] = @indicator.errors.full_messages.to_sentence
      end
    elsif !@element.nil? && !@activity.nil? && params[:task] == "Update"
      @indicator = EltIndicator.find_by_public_id(params[:elt_indicator_id]) rescue nil
      unless @indicator.nil?
        if params[:function] && params[:function] == "Update"   
          if @indicator.update_attributes(params[:elt_indicator])
            flash[:notice] = "Successfully Updated.   CLOSE WINDOW"
          else
            flash[:error] = @indicator.errors.full_messages.to_sentence
          end        
        end
        if !@indicator.nil? && params[:function] && params[:function] == "Destroy"      
          EltRelatedIndicator.for_lookfor(@indicator.id).destroy_all
          if @indicator.destroy
            flash[:notice] = "Indicator Destoyed.   CLOSE WINDOW"
            
            @indicator = EltIndicator.new
            @task = "New"
          else
            flash[:error] = @indicator.errors.full_messages.to_sentence
          end        
        end
      else
        @indicator = EltIndicator.new
      end       
    else
      @indicator = EltIndicator.new
    end
  end 

  def maintain_plan_type
    @task = params[:task]
    if params[:function] && params[:function] == "New"
      @plan_type = EltPlanType.new(params[:elt_plan_type])
      if @current_organization.elt_plan_types << @plan_type
        flash[:notice] = "Successfully created activity.   CLOSE WINDOW"
      else
        flash[:error] = @plan_type.errors.full_messages.to_sentence
      end
    elsif @task == "Update"
      @plan_type = EltPlanType.find_by_public_id(params[:elt_plan_type_id]) rescue nil
      unless @plan_type.nil?
        if params[:function] && params[:function] == "Update"   
          if @plan_type.update_attributes(params[:elt_plan_type])
            flash[:notice] = "Successfully Updated.   CLOSE WINDOW"
          else
            flash[:error] = @plan_type.errors.full_messages.to_sentence
          end        
        end
        if !@plan_type.nil? && params[:function] && params[:function] == "Destroy"      
          if @plan_type.destroy
            flash[:notice] = "Plan Type Destoyed.   CLOSE WINDOW"
            @plan_type = EltPlanType.new
            @task = "New"
          else
            flash[:error] = @plan_type.errors.full_messages.to_sentence
          end        
        end
      else
        @plan_type = EltPlanType.new
      end       
    else
      @plan_type = EltPlanType.new
    end
  end 

  def assign_cycle_activity
    activity = EltType.find_by_id(params[:activity_id]) rescue nil
    unless activity.nil? || @cycle.nil?
      if @cycle.activities.include?(activity)
        @cycle.elt_cycle_activities.for_activity(activity).each do |ca|
          ca.destroy
        end
      else
        @cycle.activities<<activity
      end
    end
    render :partial => "/apps/learning_time/assign_cycle_activities", :locals=>{:org=>@current_organization, :cycle => @cycle, :app => @app}
  end

 def assign_cycle_element
   element = EltElement.find_by_id(params[:elt_element_id]) rescue nil
   unless element.nil? || @cycle.nil?
     if @cycle.elements.include?(element)
       @cycle.elt_cycle_elements.for_element(element).each do |ce|
         ce.destroy
       end
     else
       @cycle.elements<<element
     end
   end
   render :partial => "/apps/learning_time/assign_cycle_elements", :locals=>{:cycle => @cycle}
 end

 def select_activity
    activity = EltType.find_by_id(params[:activity_id]) rescue nil
    render :partial => "/apps/learning_time/manage_indicators",
           :locals => {:framework => activity.elt_framework,
                       :to_activities => activity.organization.elt_types,
                       :from_activities => activities_from(@current_organization, @current_application),
                       :activity => activity, :from_activity => nil, :to_element => nil, :app=>@current_application}
  end

 def select_source_activity
   to_activity = EltType.find_by_id(params[:activity_id]) rescue nil
   from_activity = EltType.find_by_id(params[:from_activity_id]) rescue nil
   render :partial => "/apps/learning_time/manage_indicators",
          :locals => {:framework => to_activity.elt_framework,
                      :to_activities => to_activity.organization.elt_types,
                      :from_activities => activities_from(@current_organization, @current_application),
                      :activity => to_activity, :from_activity => from_activity,
                      :to_element => nil, :app=>@current_application}
 end

 def select_element
   to_activity = EltType.find_by_id(params[:activity_id]) rescue nil
   from_activity = EltType.find_by_id(params[:from_activity_id]) rescue nil
   render :partial => "/apps/learning_time/manage_indicators",
          :locals => {:framework => to_activity.elt_framework,
                      :to_activities => to_activity.organization.elt_types,
                      :from_activities => activities_from(@current_organization, @current_application),
                      :activity => to_activity, :from_activity => from_activity,
                      :to_element => @element, :app=>@current_application}
 end

 def copy_activity_indicators
    to_activity = EltType.find_by_id(params[:activity_id])
    from_activity = EltType.find_by_id(params[:from_activity_id])
    to_element = EltElement.find_by_id(params[:to_element_id])
    if (to_activity && from_activity && to_element && @element)
      to_activity.copy_indicators(from_activity, @element, to_element)
    end
    render :partial => "/apps/learning_time/manage_indicators",
           :locals => {:framework => to_activity.elt_framework,
                       :to_activities => to_activity.organization.elt_types,
                       :from_activities => activities_from(@current_organization, @current_application),
                       :activity => to_activity, :from_activity => from_activity,
                       :to_element => nil, :app=>@current_application}
  end 

  def refresh_element_indicator
    activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
    render :partial => "/apps/learning_time/manage_element_indicators", :locals => {:org => activity.organization, :element => @element, :activity => activity, :app=>@app}
  end

 def destroy_disabled_indicators
   activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
   EltIndicator.destroy_disabled!(activity,@element)
   render :partial => "/apps/learning_time/manage_element_indicators", :locals => {:org => activity.organization, :element => @element, :activity => activity, :app=>@app}
 end

 def move_indicator
   if params[:new_element_id]
     new_element = EltElement.find_by_public_id(params[:new_element_id]) rescue nil
   end
   if !@indicator.nil? && !new_element.nil?
     if new_element.elt_indicators << @indicator
       @indicator.support_links.each do|l|
         l.destroy
       end
     end
   end
   render :partial => "/apps/learning_time/manage_element_indicators", :locals => {:org => @activity.organization, :element => @element, :activity => @activity, :app=>@app}
 end

 def toggle_active_indicator
    @indicator = EltIndicator.find_by_public_id(params[:elt_indicator_id]) rescue nil
    activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
    unless @indicator.nil?
      @indicator.update_attributes(:is_active=> !@indicator.is_active)
    end
    render :partial => "/apps/learning_time/manage_element_indicators", :locals => {:org => activity.organization, :element => @element, :activity => activity, :app=>@app}
  end   

  def toggle_active_element
    @element = EltElement.find_by_public_id(params[:elt_element_id]) rescue nil
    unless @element.nil?
      @element.update_attributes(:is_active=> !@element.is_active)
    end
    render :partial => "/apps/learning_time/manage_elements", :locals=>{:org=>@current_organization, :framework => @element.elt_framework, :app=>@app}
  end 

  def toggle_active_activity
    @activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
    unless @activity.nil?
      @activity.update_attributes(:is_active=> !@activity.is_active)
    end
    render :partial => "/apps/learning_time/manage_activities", :locals => {:org => @current_organization, :framework => @activity.elt_framework, :app=>@app}
  end 

  def toggle_master_activity
    @activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
    unless @activity.nil? || @activity.elt_framework.nil?
      @activity.update_attributes(:is_master=> !@activity.is_master)
      @activity.elt_framework.activities.each do |act|
        unless act==@activity
          act.update_attributes(:is_master => false)
        end
      end
    end
    render :partial => "/apps/learning_time/manage_activities", :locals => {:org => @current_organization, :framework => @activity.elt_framework, :app=>@app}
  end

  def toggle_active_cycle
    unless @cycle.nil?
      @cycle.update_attributes(:is_active=> !@cycle.is_active)
    end
    render :partial => "/apps/learning_time/manage_cycles", :locals => {:org => @current_organization, :framework => @framework, :app=>@app}
  end 

  def toggle_active_plan_type
    unless @plan_type.nil?
      @plan_type.update_attributes(:is_active=> !@plan_type.is_active)
    end
    render :partial => "/apps/learning_time/manage_plan_types", :locals => {:org => @current_organization, :app=>@app} 
  end 
  
  def assign_framework_cycle
    unless @cycle.nil? || @school.nil?
      if @school.elt_org_option
        @school.elt_org_option.update_attributes(:elt_cycle_id=> @cycle.id)
      else
        org_option = EltOrgOption.new
        org_option.elt_cycle_id = @cycle.id
        @school.elt_org_option = org_option
      end
    end
    render :partial => "/apps/learning_time/manage_cycles", :locals => {:org => @current_organization, :framework => @framework, :app=>@app}
  end 
  
  def toggle_rubric
    @activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
    unless @activity.nil?
      @activity.update_attributes(:use_rubric=> !@activity.use_rubric)
    end
    render :partial => "/apps/learning_time/activate_rubric", :locals => {:entity => @activity, :app => @app} 
  end

  def share_rubric
    @activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
    rubric_id = params[:rubric_id] == 0 ? nil : params[:rubric_id].to_i
    @activity.update_attributes(:rubric_id => rubric_id)
    render :partial => "/apps/learning_time/activate_rubric", :locals => {:entity => @activity, :app => @app} 
  end    

  def delete_rubric
    rubric = Rubric.find_by_public_id(params[:rubric_id]) rescue nil
    entity = rubric.scope.nil? ? nil : rubric.scope
    unless rubric.nil? 
      rubric.destroy
    end
    render :partial => "/apps/learning_time/manage_rubrics", :locals => {:entity => entity, :app => @app} 
  end 

  def assign_option_cycle
    org = Organization.find_by_public_id(params[:org_id]) rescue nil
    unless org.nil? || !org.elt_org_option
      org.elt_org_option.update_attributes(:elt_cycle_id=>params[:cycle_id].to_i)
    end
  render :partial => "/apps/learning_time/option_cycles", :locals=>{:app=> @app, :org => (org.nil? ? @current_organization : org)}
  end

  def start_case
    @activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
    @case = EltCase.new
    @case.is_final = false
    @case.user_id = @current_user.id
    @case.organization_id = @school.id
    @case.user_name = @current_user.last_name_first
    @case.submit_date = Date.today
    @case.elt_cycle_id = @cycle.id
    @case.name = @activity.name + ',   ' +  @current_user.last_name
    @activity.elt_cases << @case
    redirect_to :action => 'show_case', :organization_id => @current_organization, :school_id=> @school, :user_id => @current_user, :elt_case_id => @case, :form => 'new'
  end

 def update_case_b
   initialize_parameters
   unless params[:commit] == 'Abort' || @case.nil?
    if params[:commit] == 'Destroy'
      @case.destroy
    else
      @case.elt_type.active_elements.each do |element|
        if params[:notes]
          update_notes(@case, element, (!params[:notes][element.public_id].nil? ? params[:notes][element.public_id] : ''))
        end
        element.elt_indicators.active.each do |indicator|
          if params[:case]
            update_indicator_note(@case, indicator, (!params[:case][indicator.id.to_s].nil? ? params[:case][indicator.id.to_s]:''))
          end
          if params[:rating]
            update_indicator_rubric(@case, indicator, (!params[:rating][indicator.id.to_s].nil? ? params[:rating][indicator.id.to_s]:''))
          end
        end
      end
    end
   end
   redirect_to :action => 'index', :organization_id => @current_organization, :user_id => @current_user
 end

 def assign_case_header
      @case.update_attributes(:name => params[:case_name])
    if params[:subject_area_id].to_i > 0
      @case.update_attributes(:subject_area_id => params[:subject_area_id].to_i)
    end
    if params[:grade_level_id].to_i > 0
      @case.update_attributes(:grade_level_id => params[:grade_level_id].to_i)
    end
    render :partial => "/apps/learning_time/show_edit_case_title", :locals => {:elt_case => EltCase.find_by_id(params[:case_id]), :app => @app}
  end

  def show_case
    initialize_parameters
  end

  def list_case_evidences
    initialize_parameters
#    @support_cases = @elt_case.organization.elt_cycle_cases(@elt_case.elt_cycle).select{|c| c!=@elt_case}
  end

 def list_case_comments
   initialize_parameters
   @supporting_comments = []
   @elt_case.organization.elt_cycle_cases(@elt_case.elt_cycle).each do |elt_case|
    if !elt_case.elt_case_notes.for_element(@element).empty? && !elt_case.elt_case_notes.for_element(@element).first.nil? && @elt_case != elt_case
        @supporting_comments << elt_case.elt_case_notes.for_element(@element).first
    end
   end
 end

 def show_evidence_map
   initialize_parameters
   org = Organization.find_by_public_id(params[:org]) rescue @current_organization
   @standards = []
   @elements =[]
   @data_points ={}
   @element_totals = {}
    @cycle.standards.each_with_idx each do |std, idx|
      @standard[idx] = std
      @elements[idx] = std.elements.active.by_position
      @activities[idx] = @cycle.activities.informing.active.by_position

    end

   grand_total = 0
   @elements.each do |element|
     @element_totals[element] ||= []
     element_total = 0
     @activities.each do |activity|
       @data_points[activity] ||= {} # Create a sub-hash unless it already exists
       @data_points[activity][element] ||= []
       cases = org.elt_cycle_activity_cases(@cycle, activity)
       scores = []
       cases.each do |c|
         scores << c.scores_for(element)
       end
       @data_points[activity][element] = scores.flatten.compact.size
       grand_total += scores.flatten.compact.size
       element_total += scores.flatten.compact.size
     end
     @element_totals[element] = element_total
   end
   render :partial => "/apps/learning_time/show_activity_map", :locals => {:activities => @activities, :elements => @elements, :touches => @data_points, :cycle => @cycle, :element_totals => @element_totals, :map_label => (grand_total.to_s + ' Findings')}
 end

 def show_activity_map
   initialize_parameters
   org = Organization.find_by_public_id(params[:org]) rescue @current_organization
   @elements = org.active_elt_cycle.nil? ? [] : org.active_elt_cycle.elements.active.by_position
   @activities = org.active_elt_cycle.nil? ? [] : org.active_elt_cycle.activities.informing.active.by_position
   @cycle = org.active_elt_cycle
   @touches ={}
   @element_totals = {}
   grand_total = 0
   @elements.each do |element|
     @element_totals[element] ||= []
     element_total = 0
     @activities.each do |activity|
       @touches[activity] ||= {} # Create a sub-hash unless it already exists
       @touches[activity][element] = activity.informing_indicators(element).size
       grand_total += activity.informing_indicators(element).size
       element_total += activity.informing_indicators(element).size
     end
     @element_totals[element] = element_total
   end
   render :partial => "/apps/learning_time/show_activity_map",
          :locals => {:activities => @activities, :elements => @elements,
                      :touches => @touches, :cycle => @cycle, :element_totals => @element_totals,
                      :map_label => (grand_total.to_s + ' Informers')}
 end

  def abort_case
    initialize_parameters  
    @elt_case.destroy
    redirect_to :action => 'index', :organization_id => @current_organization, :user_id => @current_user
  end

  def show_activity_cases
    initialize_parameters
  end

  def show_school_cycle_activity_cases
    initialize_parameters
  end

  def update_case_rubric

    initialize_parameters

    rubric_id = @rubric.nil? ? nil : @rubric.id
    if @elt_case.case_indicator(@indicator).nil?
      case_indicator = EltCaseIndicator.new
      case_indicator.elt_indicator_id = @indicator.id
      case_indicator.rubric_id = rubric_id
      @elt_case.elt_case_indicators << case_indicator  
    else
      @elt_case.case_indicator(@indicator).update_attributes(:rubric_id => rubric_id)
    end
    render :partial => "/apps/learning_time/element_indicator_rubric", :locals => {:elt_case => @elt_case, :indicator=> @indicator}
  end

  def update_case_indicator_note

    initialize_parameters

    update_indicator_note(@elt_case, @indicator, params[:note])

    render :partial => "/apps/learning_time/element_indicator_note", :locals => {:elt_case => @elt_case, :indicator=>@indicator}
  end
  
  def update_case_element_note

    initialize_parameters

    update_notes(@elt_case, @element, params[:note])

    render :partial => "/apps/learning_time/element_indicators", :locals => {:elt_case => @elt_case, :element=> @element, :app => @app, :update => true}
  end

 def assign_supported_indicator
  sup_indicator = EltIndicator.find_by_id(params[:supported_indicator_id]) 
  if sup_indicator.lookfors.include?(@indicator)
    sup_indicator.elt_related_indicators.for_lookfor(@indicator).destroy_all
  else
    sup_indicator.lookfors << @indicator
  end
  render :partial => "apps/learning_time/related_indicators", :locals=>{:indicator => @indicator}
 end

 def assign_clarifying_lookfor
  if params[:elt_indicator_lookfor_id]
    lookfor = EltIndicatorLookfor.find_by_id(params[:elt_indicator_lookfor_id]) rescue nil
    lookfor.update_attributes(:position => params[:pos].to_i, :lookfor => params[:descript])   
  else
   lookfor = EltIndicatorLookfor.new
   lookfor.position = params[:pos].to_i
   lookfor.lookfor = params[:descript]
   @indicator.elt_indicator_lookfors << lookfor
  end
  render :partial => "apps/learning_time/indicator_lookfors", :locals=>{:indicator => @indicator}
 end

 def school_cycle_plan
  if @school.elt_cycle_plan(@cycle).nil?
    new_plan = EltPlan.new
    new_plan.elt_cycle_id = @cycle.id
    @school.elt_plans << new_plan  
  else
   @school.elt_cycle_plan(@cycle).update_attributes(:is_open => !@school.elt_cycle_plan(@cycle).is_open)
  end
    render :partial => "/apps/app_report/elt_school_diag", :locals => {:provider => @provider, :app => @app, :school => @school, :cycle => @cycle, :activity => @activity}
 end
 
  def toggle_finalize_case
    @elt_case.final? ? @elt_case.unfinalize_it : @elt_case.finalize_it
    render :partial => "/apps/learning_time/show_school_cycle_activity_cases", :locals => {:activity => @elt_case.elt_type, :org => @elt_case.organization, :cycle=>@elt_case.elt_cycle, :app => @app}
  end

  def submit_case

    initialize_parameters

    if @elt_case
      @elt_case.update_attributes(:submit_date=>Date.today, :is_submitted=>true, :finalize_date=>Date.today, :is_final=>true)
    end
       redirect_to :action => :index, :organization_id=>@current_organization, :app_id=>@app 
  end

  def select_indicator_map
    initialize_parameters
    unless @elt_case && @school
      @elt_case = @current_organization.last_elt_submitted
    end
    list_type= params[:list_type] ? params[:list_type] : "A"

    render :partial => "/apps/learning_time/indicator_map_select", :locals => {:list_type => list_type ,:school=>@current_organization,  :elt_case => @elt_case, :app => @app}
  end

  def show_case_element_indicators
    initialize_parameters
  end

  def show_case_summary
    initialize_parameters   
  end
  
  def view_latest_submitted
    initialize_parameters    
  end
    
 def destroy_case
    initialize_parameters
    if @elt_case
      @elt_case.destroy
    end
    render :partial => "/apps/learning_time/list_cases", :locals=>{:app=>@app}
 end

 def new_framework
   initialize_parameters
   framework = EltFramework.new
   framework.name = params[:name]
   framework.abbrev = params[:abbrev]
   if !framework.name.strip.empty? then
     if @current_organization.elt_frameworks << framework
      if !@current_organization.elt_framework?
        @current_organization.set_framework(@current_organization.elt_frameworks.last)
      end
     end
   end
   render :partial => "/apps/learning_time/manage_frameworks", :locals => {:org => @current_organization, :app=>@app}
 end

 def set_framework
   initialize_parameters
   if @framework
     @current_organization.set_framework(@framework)
   end
   render :partial => "/apps/learning_time/maintain_frameworks", :locals=>{:app=>@app, :org => @current_organization}
 end

 def edit_framework
   initialize_parameters
   if @framework && !params[:name].strip.empty?
     @framework.update_attributes(:name => params[:name].strip, :abbrev => params[:abbrev].strip)
   end
   render :partial => "/apps/learning_time/manage_frameworks", :locals => {:org => @current_organization, :app=>@app}
 end

 def destroy_framework
   initialize_parameters
   if @framework
     @framework.destroy
     @current_organization.initial_framework
   end
   render :partial => "/apps/learning_time/manage_frameworks", :locals => {:org => @current_organization, :app=>@app}
 end
  
  def select_kb_filters
    initialize_parameters
    @rubric = @rubric.activity.elt_framework == @framework ? @rubric : (@framework.master_activity ? @framework.master_activity.shareable_rubrics.last : nil)
    render :partial => "/apps/learning_time/share_rubric_data", :locals=>{:org_type => @org_type, :framework => @framework, :rubric => @rubric, :app=>@app}
  end

  def case_indicators_element_rubric
    initialize_parameters
  end

  def transfer_case_org
    initialize_parameters
    org = Organization.find_by_public_id(params[:org_id])rescue nil
    baseorg = Organization.find_by_public_id(params[:base_org_id])rescue nil
    elt_case = EltCase.find_by_public_id(params[:elt_case_id]) rescue nil
    unless elt_case.nil?
      elt_case.reassign_it(((!params[:xfer_org_id] || (params[:xfer_org_id] == "")) ? elt_case.organization_id : params[:xfer_org_id].to_i), (!params[:xfer_cycle_id] || (params[:xfer_cycle_id] == "")) ? elt_case.elt_cycle_id : params[:xfer_cycle_id].to_i)
    end
    render :partial => "/apps/learning_time/transfer_cases", :locals => {:org => org, :base_org => baseorg, :framework => @framework, :app=>@app}
  end

 def transfer_plan_org
   initialize_parameters
   org = Organization.find_by_public_id(params[:org_id])rescue nil
   baseorg = Organization.find_by_public_id(params[:base_org_id])rescue nil
   elt_plan = EltPlan.find_by_public_id(params[:elt_plan_id]) rescue nil
   unless elt_plan.nil?
     elt_plan.reassign_it((!params[:xfer_cycle_id] || (params[:xfer_cycle_id] == "")) ? elt_plan.elt_cycle_id : params[:xfer_cycle_id].to_i)
   end
   render :partial => "/apps/learning_time/transfer_plans", :locals => {:framework => @framework, :base_org => baseorg, :app=>@app}
 end

  def send_school_cycle_survey
    initialize_parameters
    if @cycle && !@cycle.school_survey_active?
      school_survey(@cycle)  
    end
    render :partial => "/apps/learning_time/survey_client_schools", :locals=>{:cycle=>@cycle, :app=>@app}
  end

  def stop_school_cycle_surveys
    initialize_parameters
    @cycle.survey_schedules.active.each do |schedule|
      stop_survey(schedule) 
    end
    render :partial => "/apps/learning_time/survey_client_schools", :locals=>{:cycle=>@cycle, :app=>@app}
  end
 
  def update_action_plan

    initialize_parameters
    if @plan.action_for_scope(params[:scope_type], params[:scope_id]).nil?
      action = EltPlanAction.new
      action.scope_id = params[:scope_id]
      action.scope_type = params[:scope_type]
      action.rubric_id = params[:rubricid]
      action.note = params[:notes]
      action.elt_plan_id = @plan.id
      action.save
    else
      action = @plan.action_for_scope(params[:scope_type], params[:scope_id])
      action.update_attributes(:rubric_id => (params[:rubricid] == "" ? action.rubric_id : (params[:rubricid] == "0" ? nil : params[:rubricid])), :note => params[:notes])
    end
    entity = @plan.action_for_scope(params[:scope_type], params[:scope_id]).scope
    render :partial => "/apps/learning_time/school_cycle_plan", :locals => {:table_width => "450px",:cycle=> @cycle, :school => @school, :plan => @plan, :entity => entity}
  end 

  def export_case_for_excel
    @case = EltCase.find_by_public_id(params[:elt_case_id])

    respond_to do |format|
# Below produces Spreadsheet.  But the data does not correspond to the "Collect" above 
      format.xls

# Below Fails to produce spreadsheet, but the Error Message reveals the "Collect" is casuing the error.
#      format.xls { send_data @export_table.to_xls }
    end 
  end
   
  def pdf_example
    @case  = EltCase.find_by_public_id(params[:elt_case_id])
    respond_to do |format|
      format.pdf do
        render :pdf => "test",
               :template => "apps/learning_time/pdf_example.pdf.erb",
               :layout => false
      end
    end 
  end
    
   private

 def elt_allowed?
   @current_application = CoopApp.elt
   current_app_enabled_for_current_org?
 end

  def initialize_parameters 
    if  params[:organization_id]
      @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    end
    if  params[:organization_type_id]
      @org_type = OrganizationType.find_by_id(params[:organization_type_id])
    end
    
    if  params[:school_id]
      @school = Organization.find_by_public_id(params[:school_id])rescue nil
    end
    
    if  params[:provider_id]
      @provider = Organization.find_by_public_id(params[:provider_id])rescue nil
    end
    
    if params[:elt_case_id]
      @elt_case = EltCase.find_by_public_id(params[:elt_case_id]) rescue nil
      @case = EltCase.find_by_public_id(params[:elt_case_id]) rescue nil
    end
      
    if params[:elt_element_id]
      @element = EltElement.find_by_public_id(params[:elt_element_id]) rescue nil
    end
        
    if params[:elt_indicator_id]
      @indicator = EltIndicator.find_by_public_id(params[:elt_indicator_id]) rescue nil
    end
      
    if params[:elt_type_id]
      @activity = EltType.find_by_public_id(params[:elt_type_id]) rescue nil
    end
      
    if params[:elt_cycle_id]
      @cycle = EltCycle.find_by_public_id(params[:elt_cycle_id]) rescue nil
    end

    if params[:elt_framework_id]
      @framework = EltFramework.find_by_public_id(params[:elt_framework_id]) rescue nil
    end

    if params[:elt_plan_type_id]
      @plan_type = EltPlanType.find_by_public_id(params[:elt_plan_type_id]) rescue nil
    end
      
    if params[:elt_plan_id]
      @plan = EltPlan.find_by_public_id(params[:elt_plan_id]) rescue nil
    end

    if params[:case_id]
      @elt_case = EltCase.find_by_id(params[:case_id]) rescue nil
      @case = EltCase.find_by_id(params[:case_id]) rescue nil
    end
        
    if params[:indicator_id]
      @indicator = EltIndicator.find_by_id(params[:indicator_id]) rescue nil
    end
    
    if params[:element_id]
      @element = EltElement.find_by_id(params[:element_id]) rescue nil
    end
        
    if params[:rubric_id]
      @rubric = Rubric.find_by_id(params[:rubric_id]) rescue nil
    end
    if params[:app_id]
      @app = CoopApp.find_by_id(params[:app_id]) rescue nil
    end
    unless @app
      @app = CoopApp.elt
    end
    @admin = @current_user ? @current_user.elt_admin_for_org?(@current_organization) : false
  end

  def refresh_cycle      
    if params[:elt_cycle_id]
      @cycle = EltCycle.find_by_public_id(params[:elt_cycle_id]) rescue nil
    end
  end
 
 def update_notes(elt_case, element, note_text)
   unless elt_case.element_note(element).nil? && note_text == ''
    if elt_case.element_note(element).nil?
      case_note = EltCaseNote.new
      case_note.elt_element_id = element.id
      case_note.user_name = @current_user.last_name_first
      case_note.note = note_text
      elt_case.elt_case_notes << case_note  
    else
      elt_case.element_note(element).update_attributes(:note => note_text, :user_name => @current_user.last_name_first)
    end
   end
 end 

 def update_indicator_note(elt_case, indicator, note_text)
     if elt_case.case_indicator(indicator).nil?
       unless note_text == ''
        case_indicator = EltCaseIndicator.new
        case_indicator.elt_indicator_id = indicator.id
        case_indicator.note = note_text
        elt_case.elt_case_indicators << case_indicator
       end
      else
        elt_case.case_indicator(indicator).update_attributes(:note => note_text)
     end
 end

 def update_indicator_rubric(elt_case, indicator, rubric_id)
   if elt_case.case_indicator(indicator).nil?
     unless (rubric_id == '' || rubric_id == 0)
       case_indicator = EltCaseIndicator.new
       case_indicator.elt_indicator_id = indicator.id
       case_indicator.note = ''
       case_indicator.rubric_id = rubric_id
       elt_case.elt_case_indicators << case_indicator
     end
   else
     if rubric_id == '0'
       new_id = nil
     elsif rubric_id == ''
       new_id = elt_case.case_indicator(indicator).rubric_id
     else
       new_id = rubric_id.to_i
     end
     elt_case.case_indicator(indicator).update_attributes(:rubric_id => new_id)
   end
 end


  def school_survey(cycle)
      cycle.update_attributes(:survey_school_date => Date.today)
      audience = @app.tlt_survey_audiences.client.first
      type = @app.tlt_survey_types.feedback.first
      schedule_survey_app(cycle, cycle.organization, nil, audience, type, nil, nil, type.notify_default(audience), type.anon_default(audience))
      refresh_cycle
  end

  def  activities_from (org,app)
    activities = app.owner.elt_types
    if !org.appl_master?(app)
        activities += org.elt_types
    else
      activities = EltType.all_by_organization.active
    end
    activities
  end
  
end
