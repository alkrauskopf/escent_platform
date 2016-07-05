class Apps::OwnerMaintenanceController < ApplicationController

  helper :all # include all helpers, all the time  
  layout "app_owners", :except =>[:elt_manage_indicators,:app_ctl_school_month_opens, :app_ctl_school_opens,:app_ctl_school_subject_dashboards, :app_ctl_school_dashboards, :ctl_teacher_sessions, :ctl_school_teacher_listing, :core_org_status, :core_org_child_parent, :owner_show_video_session]
  
  before_filter :current_organization
  before_filter :current_user
  before_filter :current_application
  before_filter :current_user_app_superuser?

  before_filter :clear_notification, :except =>[]
  
 def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end


  def index
    @app = @current_application
  end

  def core_maintain_child_parent

  end

  def core_org_child_parent
    unless @org
 #     redirect_to  :action => "core_maintain_child_parent", :coop_app_id => @current_application
    end
  end

  def core_make_parent
    if @org
      @org.update_attribute("parent_id", nil)
    end
    render :partial => "/apps/owner_maintenance/core_org_child_parent", :locals => {:org=>@org}
  end

  def core_assign_parent
    if @org && (@org.id != params[:parent_id].to_i)
      @org.update_attribute("parent_id", params[:parent_id].to_i)
    end
    render :partial => "/apps/owner_maintenance/core_org_child_parent", :locals => {:org=>@org}
  end

  def core_maintain_statuses

  end

  def core_org_status
    unless @org
  #    redirect_to  :action => "core_maintain_statuses", :coop_app_id => @current_application
    end
  end

  def core_assign_status

    if @org
      @org.update_attribute("status_id", params[:status_id].to_i)
      @org = Organization.find_by_public_id(params[:org])
    end
    render :partial => "/apps/owner_maintenance/core_org_status", :locals => {:app => @current_application, :org=>@org}
  end

  def app_discussion_forum

  end

  def update_app_discussion_parameters
    @app = CoopApp.find(params[:app_id]) rescue nil    
    if @app && params[:color_code]
      @app.app_discussion.update_attributes(:background_color=>params[:color_code])
    end
  render :partial => "/apps/owner_maintenance/app_discussion_owner_maintenance", :locals => {:app => @app}
  end

  def app_ctl_dashboards

  end
  
  def app_ctl_school_dashboards
    @school = Organization.find_by_public_id(params[:org_id])
  end

  def app_ctl_school_subject_dashboards
    @school = Organization.find_by_public_id(params[:org_id])
    @subject = SubjectArea.find_by_public_id(params[:subject_id])
  end

  def app_ctl_open_sessions

  end
  
  def app_ctl_school_opens
    @school = Organization.find_by_public_id(params[:org_id])
  end 

  def app_ctl_school_month_opens
    @school = Organization.find_by_public_id(params[:org_id])
    @month = DateTime.parse(params[:session_month]) rescue nil
  end
  
  def destroy_open_sessions
    @app = CoopApp.find(params[:app_id]) rescue nil    
    @school = Organization.find_by_public_id(params[:org_id])
    @month = DateTime.parse(params[:session_month]) rescue nil    
    @school.tlt_sessions.between_dates(@month.at_beginning_of_month, @month.at_end_of_month ).backlog.completed.destroy_all
    render :partial => "/apps/owner_maintenance/app_ctl_school_month_opens", :locals => {:app => @app, :school=>@school, :month=>@month}
  end

  def destroy_open_session
    @app = CoopApp.find(params[:app_id]) rescue nil    
    @school = Organization.find_by_public_id(params[:org_id])
    @month = DateTime.parse(params[:session_month]) rescue nil    
    session = TltSession.find_by_public_id(params[:tlt_session_id]) rescue nil
    unless session.nil? || session.finalized?
       session.destroy
    end 
    render :partial => "/apps/owner_maintenance/app_ctl_school_month_opens", :locals => {:app => @app, :school=>@school, :month=>@month}
  end

   
  def owner_strategies

  end

  def owner_strategy_evidence
    @app = CoopApp.find_by_id(params[:app_id])
    @strategy = TlActivityTypeTask.find_by_id(params[:strategy_id]) 
    evidence = TlActivityTypeTask.find_by_id(params[:evidence_id]) 
    if @strategy.evidences.include?(evidence)
      @strategy.itl_strategy_evidences.select{|se| se.evidence_id == evidence.id}.first.destroy 
    else
      se = ItlStrategyEvidence.new
      se.evidence_id = evidence.id
      se.tl_activity_type_task_id = @strategy.id
      se.save
    end
    @strategy = TlActivityTypeTask.find_by_id(params[:strategy_id])
    render :partial => "/apps/owner_maintenance/owner_strategy_evidences", :locals => {:app => @app, :strategy=>@strategy}  
  end

  def owner_strategy_thresholds

  end

  def owner_strategy_edit
    if params[:strategy_id]
      @strategy =TlActivityTypeTask.find_by_id(params[:strategy_id])  rescue nil
    end
  end

  def owner_strategy_update
    return if request.get?
    if params[:strategy_id]
      @strategy =TlActivityTypeTask.find_by_id(params[:strategy_id])  rescue nil
    end
    if @strategy 
      if @strategy.tl_strategy_desc.nil?
        descript = TlStrategyDesc.new
        descript.tl_activity_type_task_id = @strategy.id
        descript.description = params[:tl_strategy_desc][:description]
        descript.research = params[:tl_strategy_desc][:research]
        descript.save
      else
        @strategy.tl_strategy_desc.update_attributes params[:tl_strategy_desc]
      end
    end
      redirect_to  :action => "owner_strategies", :coop_app_id => @current_application
  end

  def owner_thresholds_edit
    if params[:strategy_id]
      @strategy =TlActivityTypeTask.find_by_id(params[:strategy_id])  rescue nil
    end
    if @strategy && params[:commit]=="Save"
      thresh = @strategy.itl_strategy_threshold.nil? ? ItlStrategyThreshold.new : @strategy.itl_strategy_threshold
      thresh.tl_activity_type_task_id = @strategy.id
      thresh.min_minutes = params[:itl_strategy_threshold][:min_minutes]=="" ? nil : params[:itl_strategy_threshold][:min_minutes]
      thresh.max_minutes = params[:itl_strategy_threshold][:max_minutes]== "" ? nil : params[:itl_strategy_threshold][:max_minutes]
      thresh.min_minutes_msg = params[:itl_strategy_threshold][:min_minutes]=="" ? nil : params[:itl_strategy_threshold][:min_minutes_msg] 
      thresh.max_minutes_msg = params[:itl_strategy_threshold][:max_minutes]=="" ? nil : params[:itl_strategy_threshold][:max_minutes_msg] 
      thresh.min_pct = params[:itl_strategy_threshold][:min_pct]=="" ? nil : params[:itl_strategy_threshold][:min_pct]
      thresh.max_pct = params[:itl_strategy_threshold][:max_pct]=="" ? nil : params[:itl_strategy_threshold][:max_pct]
      thresh.min_pct_msg = params[:itl_strategy_threshold][:min_pct]=="" ? nil : params[:itl_strategy_threshold][:min_pct_msg]
      thresh.max_pct_msg = params[:itl_strategy_threshold][:max_pct]=="" ? nil : params[:itl_strategy_threshold][:max_pct_msg]
      if thresh.save
        redirect_to  :action => "owner_strategy_thresholds", :coop_app_id => @current_application
      else 
        @min_minute = thresh.min_minutes
        @min_minute_msg = thresh.min_minutes_msg
        @max_minute = thresh.max_minutes
        @max_minutes_msg = thresh.max_minutes_msg       
        @min_pct = thresh.min_pct
        @min_pct_msg = thresh.min_pct_msg
        @max_pct = thresh.max_pct
        @max_pct_msg = thresh.max_pct_msg
        flash[:error] = thresh.errors.full_messages.to_sentence  
      end
    elsif @strategy.nil? 
      flash[:error] ="Invalid Strategy"
    elsif @strategy.itl_strategy_threshold
        @min_minute = @strategy.itl_strategy_threshold.min_minutes
        @min_minute_msg = @strategy.itl_strategy_threshold.min_minutes_msg
        @max_minute = @strategy.itl_strategy_threshold.max_minutes
        @max_minutes_msg = @strategy.itl_strategy_threshold.max_minutes_msg       
        @min_pct = @strategy.itl_strategy_threshold.min_pct
        @min_pct_msg = @strategy.itl_strategy_threshold.min_pct_msg
        @max_pct = @strategy.itl_strategy_threshold.max_pct
        @max_pct_msg = @strategy.itl_strategy_threshold.max_pct_msg      
    end
  end


  def owner_blackbelt_maint

  end

  def owner_show_video_session
    if params[:video_id]
      @video = Content.find_by_public_id(params[:video_id])  rescue nil
    end  
  end

  def toggle_blackbelt_session
    if params[:tlt_session_id]
      @tlt_session = TltSession.find_by_public_id(params[:tlt_session_id]) rescue nil
    end
    if @tlt_session && @tlt_session.itl_blackbelt       
        user_id = @tlt_session.itl_blackbelt.observer_id
        if @tlt_session.itl_blackbelt.destroy
          @tlt_session.update_attributes(:user_id=>user_id, :is_final=>false, :is_observer_done=>false, :is_teacher_done=>false)
        end
     elsif @tlt_session.content
       if @tlt_session.content.itl_blackbelt
         user_id =  @tlt_session.content.itl_blackbelt.observer_id
         previous_session = @tlt_session.content.itl_blackbelt.tlt_session rescue nil
         @tlt_session.content.itl_blackbelt.destroy 
         unless previous_session.nil?
           previous_session.update_attributes(:user_id=>user_id, :is_final=>false, :is_observer_done=>false, :is_teacher_done=>false) 
         end
       end
       blackbelt = ItlBlackbelt.new
       blackbelt.content_id = @tlt_session.content_id
       blackbelt.tlt_session_id = @tlt_session.id
       blackbelt.observer_id = @tlt_session.user_id
       if blackbelt.save
         @tlt_session.update_attributes(:user_id=>0, :is_final=>true, :is_observer_done=>true, :is_teacher_done=>true, :finalize_date=>Date.today, :observer_done_date=>Date.today, :teacher_done_date=>Date.today)
       end
      refresh_session
    end 
    render :partial => "/apps/owner_maintenance/owner_show_video_session", :locals => {:app => @current_application, :video=>@tlt_session.content}
  end


  def ctl_school_listing
    @app = CoopApp.find(params[:app_id]) rescue nil
  end
  
  def ctl_school_teacher_listing
    @app = CoopApp.find(params[:app_id]) rescue nil    
    @org =Organization.find_by_public_id(params[:organization_id])  rescue nil 
  end

  def ctl_teacher_sessions
    @app = CoopApp.find(params[:app_id]) rescue nil    
    @org =Organization.find_by_public_id(params[:organization_id])  rescue nil 
    @teacher = User.find_by_public_id(params[:user_id])  rescue nil 
  end

  def ctl_destroy_session 
    session = TltSession.find_by_public_id(params[:tlt_session_id]) rescue nil
    if session
      remove_summary_data(session)
      if session.destroy
        s_msg = "Session Removed. "
      else
        s_msg = "Session NOT Removed. "
      end
      flash[:notice] = s_msg + flash[:notice]
    else
      flash[:error] = "No Session"
    end
    render :partial => "/apps/owner_maintenance/ctl_teacher_sessions", :locals => {:teacher => session.user}
  end

  def elt_select_type
    if params[:app_id]
      @app = CoopApp.find_by_id(params[:app_id])
    else 
      @app = CoopApp.etl.first 
    end
    render :partial => "/apps/owner_maintenance/elt_tables", :locals=>{:app=>@app, :activity => (EltType.find_by_id(params[:elt_type_id]) rescue nil)} 
  end 

  def elt_indicator_new
    @task = params[:task]
    @activity = EltType.find_by_public_id(params[:elt_type_id])
    if !@activity.nil? && params[:function] && params[:function] == "New"
      @indicator = EltIndicator.new(params[:elt_indicator])
      @indicator.is_active = true
      @indicator.elt_type_id = @activity.id
      if @indicator.save
        flash[:notice] = "Successfully Created " + @activity.name + " Indicator.   CLOSE WINDOW"
      else
        flash[:error] = @indicator.errors.full_messages.to_sentence
      end
    elsif !@activity.nil? && params[:task] == "Update"
      @indicator = EltIndicator.find_by_public_id(params[:elt_indicator_id]) rescue nil
      unless @indicator.nil?
        if params[:function] && params[:function] == "Update"
          params[:elt_indicator][:elt_element_id] = (params[:elt_indicator][:elt_element_id] == "") ? (@indicator.elt_element_id) : (params[:elt_indicator][:elt_element_id])
          if @indicator.update_attributes(params[:elt_indicator])
            flash[:notice] = "Successfully Updated.   CLOSE WINDOW"
          else
            flash[:error] = @indicator.errors.full_messages.to_sentence
          end        
        end
        if !@indicator.nil? && params[:function] && params[:function] == "Destroy"      
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
  
  def elt_element_edit
    if params[:element_id]
      @element = EltElement.find_by_id(params[:element_id])
    end
  end

  def elt_element_update
    if params[:commit] == "Add"
     element = EltElement.new
     element.name = params[:elt_element][:name]
     element.position = params[:elt_element][:position]
     element.abbrev = params[:elt_element][:abbrev]
     element.description = params[:elt_element][:description]
     element.form_background = params[:elt_element][:form_background]
     element.i_form_background = params[:elt_element][:i_form_background]
     element.e_font_color = params[:elt_element][:e_font_color]
     element.is_active = false
     element.elt_standard_id = params[:elt_element][:elt_standard_id]
     element.save
    else
      @element = EltElement.find_by_id(params[:element_id])
      if @element && params[:commit]=="Save"
        old_id = @element.elt_standard_id
        @element.update_attributes(params[:elt_element])
        if params[:elt_element][:elt_standard_id] == ''
          @element.update_attributes(:elt_standard_id => old_id)
        end
      elsif @element && params[:commit]=="Destroy"
        @element.destroy
      end
    end
    redirect_to :action=>'index', :organization_id => @current_organization, :coop_app_id=> @current_application
  end
  
  def elt_element_add

  end
   
  def elt_indicator_add
    if params[:element_id]
      @element = EltElement.find_by_id(params[:element_id])
    end
  end
    
  def elt_indicator_edit
    if params[:indicator_id]
      @indicator = EltIndicator.find_by_id(params[:indicator_id])
    end
  end

  def elt_indicator_update
    if params[:commit] == "Add"
     @element = EltElement.find_by_id(params[:element_id]) 
     indicator = EltIndicator.new
     indicator.position = params[:elt_indicator][:position]
     indicator.weight = params[:elt_indicator][:weight]
     indicator.ind_num = params[:elt_indicator][:ind_num]
     indicator.indicator = params[:elt_indicator][:indicator]
     indicator.is_active = false
     @element.elt_indicators << indicator
    else
      @indicator = EltIndicator.find_by_id(params[:indicator_id])
      if @indicator && params[:commit]=="Save"
        @indicator.update_attributes(params[:elt_indicator])
      elsif @indicator && params[:commit]=="Destroy"
        @indicator.destroy
      end
    end
    redirect_to :action=>'index', :organization_id => @current_organization, :coop_app_id=> @current_application
  end
     
  def toggle_element
    if params[:element_id]
      @element = EltElement.find_by_id(params[:element_id])
      @element.update_attributes(:is_active=> !@element.is_active)
      @element = EltElement.find_by_id(params[:element_id])
    end
    if @element
      render :partial => "/apps/owner_maintenance/elt_element_table", :locals => {:element => @element}
    else
      redirect_to :action=>'index', :organization_id => @current_organization, :app_id=> @app.id   
    end
  end    
   
  def elt_toggle_indicator
      @indicator = EltIndicator.find_by_public_id(params[:elt_indicator_id]) rescue nil 
      @indicator.update_attributes(:is_active=> !@indicator.is_active) rescue nil
      @indicator = EltIndicator.find_by_public_id(params[:elt_indicator_id]) rescue nil
      render :partial => "/apps/owner_maintenance/elt_indicator_table", :locals => {:element => (@indicator ? @indicator.elt_element : nil), :activity => (@indicator ? @indicator.elt_type : nil)}
  end

   private

  def refresh_session
    @tlt_session = TltSession.find_by_public_id(params[:tlt_session_id]) rescue nil
  end

  def remove_summary_data(session)
    summary = session.classroom ? session.classroom.itl_summaries.where('yr_mnth_of=? AND itl_belt_rank_id = ?',session.session_date.beginning_of_month, session.itl_belt_rank_id).first : nil
    sumrys_destroyed = 0
    sumrys_mod = 0
    smry_strats_destroyed = 0
    smry_strats_mod = 0
    if summary && summary.observation_count <= 1
      summary.destroy
      sumrys_destroyed += 1      
    elsif summary
      summary.observation_count -= 1
      summary.classroom_duration -= session.duration
      summary.observation_duration -= session.session_length
      if summary.save    
        sumrys_mod += 1
        session.tlt_session_logs.collect{|l| l.tl_activity_type_task}.uniq.each do |strat|
          strategy_summary = summary.itl_summary_strategies.for_strategy(strat).first 
          if strategy_summary && strategy_summary.segments == session.tlt_session_logs.for_task(strat).size 
            if summary.itl_summary_strategies.for_strategy(strat).destroy_all
              smry_strats_destroyed += 1
            end
          else
            strategy_summary.duration -= session.tlt_session_logs.for_task(strat).collect{|l| l.duration}.sum
            strategy_summary.segments -= session.tlt_session_logs.for_task(strat).size          
            strategy_summary.engage_total -= session.tlt_session_logs.for_task(strat).collect{|l| l.involve_score}.compact.sum
            strategy_summary.engage_segments -= session.tlt_session_logs.for_task(strat).select{|l| l.involve_score}.size
            if strategy_summary.save
              smry_strats_mod += 1
            end        
          end
        end
      end
    end
    flash[:notice] = "SUMMARIES Destroyed: " + sumrys_destroyed.to_s + ", Changed: " + sumrys_mod.to_s + "SMRY_STRATEGIES Destroyed: " +  smry_strats_destroyed.to_s + ", Changed: " + smry_strats_mod.to_s
  end

  protected

  def current_app
    @current_application ||= CoopApp.find_by_public_id(params[:coop_app_id])
  end

  def access_denied(message=nil)
    redirect organization_view_path(:organization_id => @current_organization)
  end

  def access_denied_x(message=nil)
    @login_url = organization_view_url(:organization_id => @current_organization)
    #untrack_administrator
    self.current_user = nil
    
    flash[:error] = message unless message.blank?
    respond_to do |format|
      format.html { (redirect_to @login_url and return false) }
      format.js do
        render :update do |p|
          p << "location.href = '#{@login_url}';"
        end and return false
      end
    end
    false
  rescue ActionController::DoubleRenderError
    false
  end

end
