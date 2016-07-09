class Master::CoopAppsController < Master::ApplicationController
  layout "crud"
  before_filter :find_organization, :only => [:edit, :show, :delete]
  before_filter :initialize_parameters
  
  
  def index
    unless params[:msg].nil? || params[:msg]==""
      flash[:notice]  = params[:msg]
    else
      clear_notification
    end
  end

  def edit_app
    clear_notification
    @function = params[:function]
    if @function == "New"
      @app = CoopApp.new
    elsif @function == "Maintain"
      unless @app.nil?
        @function = "Edit"
       else
         @app = CoopApp.new
         @function = "New"
       end
    elsif @function == "Create"
      @app = CoopApp.new(params[:coop_app])
      @app.abbrev = @app.abbrev.upcase
      @app.is_available = false
      @app.owner_id = Organization.default.id
      if @app.save
        create_app_settings(@app, Organization.default, true, true, true, @app.abbrev, @app.name, @app.owner_id)
        flash[:notice] = "New Application Created.   CLOSE WINDOW"
        @function = "Edit"
      else
        flash[:error] = @app.errors.full_messages.to_sentence
        @function = "New"
      end      
    elsif @function == "Edit"
      unless @app.nil?
        params[:coop_app][:abbrev] = params[:coop_app][:abbrev].upcase
        params[:coop_app][:owner_id] = params[:coop_app][:owner_id] == "" ? @app.owner_id : params[:coop_app][:owner_id]
        unless params[:add_provider][:id] == "" 
          provider = Organization.find_by_public_id(params[:add_provider][:id])
          toggle_app_provider(@app, provider)
          provider.set_org_options(@app, true)
        end
        unless !params[:remove_provider] || params[:remove_provider][:id] == "" 
          provider = Organization.find_by_public_id(params[:remove_provider][:id])
          toggle_app_provider(@app, provider)
        end
        unless params[:add_not_allow][:id] == "" 
          org = Organization.find_by_public_id(params[:add_not_allow][:id])
          toggle_app_allow(@app, org)
        end
        unless !params[:remove_not_allow] || params[:remove_not_allow][:id] == "" 
          org = Organization.find_by_public_id(params[:remove_not_allow][:id])
          toggle_app_allow(@app, org)
        end
        if @app.update_attributes(params[:coop_app])
          flash[:notice] = "App Updated"
        else
          flash[:error] = @app.errors.full_messages.to_sentence
        end 
      else
        flash[:error] = "Application Not Found"
        @app = CoopApp.new
        @function = "New"        
      end
    elsif @function == "Destroy"
      unless @app.nil?
        if @app.destroy
          flash[:notice] = "App Destroyed"
          @app = CoopApp.new
          @function = "Destroyed"  
        else
          flash[:error] = @app.errors.full_messages.to_sentence
          @function = "Edit"  
        end 
      else
        flash[:error] = "Application Not Found"
        @app = CoopApp.new
        @function = "New"        
      end     
     end
  end

  def edit_app_settings
    clear_notification
    @function = params[:function]
    @org = Organization.find_by_public_id(params[:org_id]) rescue nil
    unless @app.nil? || @org.nil?
      if @org.app_settings(@app).nil?
        create_app_settings(@app, @org, false, false, true, "", "", @org.id)
        @org = Organization.find_by_public_id(params[:org_id]) rescue nil
      end
      if @function == "Edit"
          params[:coop_app_organization][:alt_abbrev] = params[:coop_app_organization][:alt_abbrev].upcase
          if @org.app_settings(@app).update_attributes(params[:coop_app_organization])
            flash[:notice] = "App Settings Updated"
          else
            flash[:error] = @app.app_settings(@app).errors.full_messages.to_sentence
          end 
      end
      @function = "Edit"
    else
      redirect_to :controller => "/master/application", :action => :index, :organization_id => @current_organization
    end
  end
  
  def toggle_provider  
    app = CoopApp.find_by_id(params[:app_id]) rescue nil
    provider = Organization.find_by_public_id(:params[:provider_id]) rescue nil
    if !provider.nil? && !app.nil? && provider.app_settings(app)
      abbrev = provider.app_settings(app).alt_abbrev.nil? ? app.abbrev : provider.app_settings(app).alt_abbrev
      name = provider.app_settings(app).alt_name.nil? ? app.name : provider.app_settings(app).alt_name
      provider.app_settings(app).update_attributes(:is_owner => !provider.app_settings(app).is_owner, :alt_abbrev => abbrev, :alt_name => name)
    end
    render :partial => "master/coop_apps/manage_coop_apps", :locals => {:app=>app}
  end

  def update_provider_alts
    app = CoopApp.find_by_id(params[:app_id]) rescue nil
    provider = Organization.find_by_public_is(:params[:provider_id]) rescue nil
    if !provider.nil? && !app.nil? && provider.app_settings(app)
      params[:alt_abbrev] = params[:alt_abbrev].upcase
      provider.app_settings(app).update_attributes(:alt_abbrev => params[:alt_abbrev], :alt_name => params[:alt_name])
    end
    render :partial => "master/coop_apps/manage_coop_apps", :locals => {:provider=> provider, :app=>app}
    
  end

  def core_maintain_child_parent
    clear_notification
  end

  def create_org_core_options
    clear_notification
     count = 0
    Organization.all.each do |org|
      org.organization_core_option = OrganizationCoreOption.new
      count +=1
    end

  redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " Organizations with Core Options"
  end


  def assign_core_blogs
    clear_notification
     count = 0
    core_app = CoopApp.core
    Blog.all.each do |blog|
      if blog.coop_app_id.nil?
        core_app.blogs<<blog
        count +=1
      end
    end
  redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " Blogs Assigned To Core"
  end

  def elt_orphan_elements
    # Empty & Inactive Standard to put all orphaned element in
    standard = EltStandard.for_orphans
    o_count = 0
    unless standard.nil?
      orphans = EltElement.orphans
      orphans.each do |o|
        standard.elt_elements << o
        o_count += 1
      end
      orphan_message = "#{o_count.to_s} Element Orphans Assigned to Standard: #{standard.abbrev}"
    else
      orphan_message = 'No Available Standard For Orphan Elements'
    end
    redirect_to :action=>'index', :app_id=> @app.id, :msg => orphan_message
  end

  def elt_copy_indicators_select
    clear_notification
    @source_activity = nil
    @dest_activity = nil
  end

  def elt_remove_null_notes
    clear_notification
    count = 0
    EltCaseIndicator.all.each do |indicator|
      if indicator.note.nil?
        indicator.update_attributes(:note =>'')
        count += 1
      end
    end
    redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " Cases Indicator Notes Corrected "
  end

  def elt_cycle_summaries
    clear_notification
    i_count = 0
    e_count = 0
    EltCycleSummary.all.destroy_all
    EltCase.final.each do |elt_case|
      if elt_case.rubric? && elt_case.elt_cycle
        elt_case.elt_case_indicators.each do |case_indicator|
          unless case_indicator.score.nil? || !case_indicator.elt_indicator
            indicator = case_indicator.elt_indicator
            if elt_case.elt_cycle.summary_for_indicator(indicator)
              if elt_case.elt_cycle.summary_for_indicator(indicator).update_attributes(:score_total => (elt_case.elt_cycle.summary_for_indicator(indicator).score_total + case_indicator.score), :score_count => (elt_case.elt_cycle.summary_for_indicator(indicator).score_count + 1))                
              i_count +=1
              end            
            else
              summary_record = EltCycleSummary.new 
              summary_record.elt_indicator_id = indicator.id
              summary_record.elt_type_id = elt_case.elt_type_id
              summary_record.elt_cycle_id = elt_case.elt_cycle_id
              summary_record.score_total = case_indicator.score
              summary_record.score_count = 1 
              if summary_record.save
              i_count +=1
              end          
            end
          end
        end
      e_count +=1
      end
    end
    redirect_to :action => :index, :app_id => @app.id, :msg => e_count.to_s + " Cases Summarized,  " + i_count.to_s + " Indicators Updated,  "
  end
  
  def elt_supporting_indicators
    clear_notification
     count = 0
      EltIndicator.all.each do |ind|
      if ind.parent && !ind.parent.lookfors.include?(ind)
        ind.parent.lookfors << ind
        count +=1
      end
    end
  redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " EE Indicator LookFors Updated"
  end
  
  def elt_destroy_nil_activity_cases
    clear_notification
     count = 0
      EltCase.all.each do |elt_case|
      if elt_case.elt_type_id.nil? || !elt_case.elt_type
        elt_case.destroy
        count +=1
      end
    end
  redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " Nil Activity Cases Destroyed"
  end

  def elt_transfer_case
    clear_notification
     
      message = "Transfer Failed"
      elt_case = EltCase.find_by_public_id(params[:elt_case_id]) rescue nil
     new_org = Orgnaization.find_by_id(params[:org_id].to_i) rescue nil
     cycle = EltCycle.find_by_id(params[:cycle_id].to_i) rescue nil
     unless elt_case.nil? || new_org.nil?
      elt_case.update_attributes(:organization_id => new_org.id, :elt_cycle_id => cycle.nil? ? elt_case.elt_cycle_id : cycle.id)
      message = "Transfer Completed"
     end
    redirect_to :action => :index, :app_id => @app.id, :msg => message
  end

  def ctl_adjust_evidence_ratings
    clear_notification
    count= 0
    AppMethod.ie.first.tl_activity_types.each do |activity|
      activity.tl_activity_type_tasks.each do|task|
        task.tlt_session_logs.each do |log|
          if log.involve == "Few"
            if log.update_attributes(:involve_score=> 0, :involve=> "Low")
              count+= 1
            end
          elsif log.involve == "Some" || log.involve == "Most" || log.involve == "Moderate"
            if log.update_attributes(:involve_score=> 2, :involve=>"Moderate")
              count+= 1
            end
          elsif log.involve == "All" || log.involve == "High"
            if log.update_attributes(:involve_score=> 4, :involve=>"High")
              count+= 1
            end
          end
        end
      end
    end
  redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " IE session logs had Effective ratings adjusted."
  end

  def ctl_set_nul_belts
    clear_notification
    count= 0
    TltSession.all.each do |session|
      if session.itl_belt_rank_id.nil?
        if session.update_attributes(:itl_belt_rank_id => 99)
          count+= 1
        end
      end
    end
  redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " sessions have assigned default belt ranking."
  end

  def ctl_destroy_observations
    clear_notification
      count= 0
      org_count = 0
      @app.organizations.each do |app_org|
        org_count += 1
        count+= TltSession.destroy_sessions(app_org, params[:status])
      end
      flash[:notice] = count.to_s + " #{params[:status].capitalize} Observations Destroyed.  For " + org_count.to_s + " Organizations"
      @trigger = nil
    render :action => :index
#    redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " sessions have been finalized."
  end

  def ctl_set_finalize_dates
    clear_notification
    count= 0
    TltSession.all.each do |session|
      unless session.observer_done_date.nil?
        if session.finalize_date.nil?
          if session.update_attributes(:finalize_date => session.observer_done_date, :is_final=>true)
            count+= 1
          end
        end
      end
    end
  redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " sessions have been finalized."
  end

  def ctl_backload_itl_template_ids
    clear_notification
    count= 0
    TltSession.all.each do |session|
      unless session.itl_template || !session.organization
          if session.organization.itl_templates.empty?
            template = ItlTemplate.first
          else
            template = session.organization.default_template ? session.organization.default_template : session.organization.itl_templates.first
          end
          if session.update_attributes(:itl_template_id => template.id)
            count+= 1
          end
      end
    end
  redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " sessions had template ID assigned."
  end

   def ctl_update_session_summary_tables
  
      ItlSummary.destroy_all
      sumry_count= 0
      sumry_strat_count = 0      
      TltSession.final.each do |session|
        # summary = ItlSummary.find(:first, :conditions=>["classroom_id=? AND yr_mnth_of=?", session.classroom_id,session.session_date.beginning_of_month]) rescue nil
        summary = session.classroom.nil? ? nil : session.classroom.itl_summaries.for_month(session.session_date.beginning_of_month).first
        if summary
         summary.observation_count += 1
         summary.classroom_duration += session.duration
         summary.observation_duration += session.session_length
        else
          sumry_count += 1          
          summary = ItlSummary.new
          summary.organization_id = session.organization_id
          summary.classroom_id = session.classroom_id
          summary.yr_mnth_of = session.session_date.beginning_of_month
          summary.subject_area_id = session.subject_area_id
          summary.organization_type_id = session.organization.organization_type_id
          summary.observation_count = 1
          summary.classroom_duration = session.duration
          summary.observation_duration = session.session_length
        end
        if summary.save
            session.tlt_session_logs.collect{|l| l.tl_activity_type_task}.uniq.each do |strat|
              strategy_summary = summary.itl_summary_strategies.for_strategy(strat).first 
              if strategy_summary
                strategy_summary.duration += session.tlt_session_logs.for_task(strat).collect{|l| l.duration}.sum
                strategy_summary.segments += session.tlt_session_logs.for_task(strat).size           
                strategy_summary.engage_total += session.tlt_session_logs.for_task(strat).collect{|l| l.involve_score}.compact.sum
                strategy_summary.engage_segments += session.tlt_session_logs.for_task(strat).select{|l| l.involve_score}.size
                strategy_summary.save
              else
                sumry_strat_count += 1 
                strategy_summary = summary.itl_summary_strategies.new
                strategy_summary.tl_activity_type_task_id = strat.id
                strategy_summary.duration = session.tlt_session_logs.for_task(strat).collect{|l| l.duration}.sum
                strategy_summary.segments = session.tlt_session_logs.for_task(strat).size           
                strategy_summary.engage_total = session.tlt_session_logs.for_task(strat).collect{|l| l.involve_score}.compact.sum
                strategy_summary.engage_segments = session.tlt_session_logs.for_task(strat).select{|l| l.involve_score}.size
                strategy_summary.save
              end
            end
        end
      end
  redirect_to :action => :index, :app_id => @app.id, :msg => TltSession.final.size.to_s + " " + @app.abbrev + " Sessions,  " + sumry_count.to_s + " Summary Records,  " + sumry_strat_count.to_s + " Strategy Records"
   end 


  def clsrm_lu_folder_position_init
    clear_notification
     count = 0
      lu_count = 0
    TopicContent.foldered.collect{|tc| tc.topic}.compact.uniq.each do |lu|
      unless lu.folder_positions.empty?
        lu.folder_positions.destroy_all
      end
      lu.folders.each_with_index do |folder, idx|
        fp= FolderPosition.new
        fp.folder_id = folder.id
        fp.position = idx+ 1
        lu.folder_positions << fp
        count +=1
      end
      lu_count += 1
    end
  redirect_to :action => :index, :app_id => @app.id, :msg => count.to_s + " Total LU Folder Positions Created For " + lu_count.to_s + " LU's"
  end

  def clsrm_mass_name_change
    clear_notification
    txt_from = params[:text][:from]
    txt_to = params[:text][:to]
    org = Organization.find_by_id(params[:org][:id]) rescue nil
    count = 0
    org.classrooms.each do |clsrm|
      new_name = clsrm.course_name.gsub(txt_from, txt_to)
      unless new_name == clsrm.course_name
        clsrm.update_attributes(:course_name=> new_name)
        count +=1
      end
    end
  redirect_to :action => :index, :app_id => @app.id, :msg => org.name + ": " + count.to_s + " Name Changes From " + txt_from + " To " + txt_to + "."
  end

  protected
  
  def initialize_parameters
    @app = CoopApp.find_by_id(params[:app_id]) rescue nil
    if params[:strategy_id]
      @strategy =TlActivityTypeTask.find_by_id(params[:strategy_id])  rescue nil
    end 

    if params[:tlt_session_id]
      @session =TltSession.find_by_public_id(params[:tlt_session_id])  rescue nil
    end

  end

  def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end

  def refresh_session
    if params[:tlt_session_id]
      @session =TltSession.find_by_public_id(params[:tlt_session_id])  rescue nil
    end
  end

end
