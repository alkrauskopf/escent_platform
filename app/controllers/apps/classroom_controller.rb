class Apps::ClassroomController < ApplicationController

 layout "classroom_admin", :except=>[:offering_views, :offering_folder_views, :show_content, :show_lu_resources, :offering_folder_setup,
                                     :offering_folders, :offering_surveys, :offering_homeworks, :offering_students, :offering_referrals,
                                     :offering_resources, :offering_periods, :offering_lus, :destroy_classroom, :toggle_active, :assign_students,
                                     :list_students, :survey_classroom_schedule, :survey_classroom_results, :question_aggregation,
                                     :register_classroom, :manage_period_students, :subject_offerings, :offering_folder_masteries, :offering_folder_benchmarks]

 before_filter :classroom_allowed?, :except=>[]
# before_filter :current_user_app_authorized?, :except=>[:self_register_student,:register_classroom, :self_unregister_student,:show_lu_resources,:list_folder_resources, :show_content]
  before_filter :current_user_app_authorized?, :only=>[:index]
  before_filter :current_user_app_admin?, :only=>[:utilities, :admin_destroy_folder, :admin_folders_copy]
  before_filter :clear_notification
 before_filter :increment_app_views, :only=>[:index]


  def index
    initialize_parameters
    if !@current_user.classroom_admin_for_org?(@current_organization)
      @teacher = @current_user
      @admin_orgs = []
    else
      @admin_orgs = @current_user.app_admin_orgs(@current_application).select{|o| o != @current_organization}
    end
    ifa_instance_variables
  end

  def utilities
    initialize_parameters
    administratable_orgs
  end

  def admin_destroy_folder
    initialize_parameters
    get_folder
    if @folder && @folder.destroy
      flash[:notice] = 'Folder Destroyed'
    elsif @folder
      flash[:error] = @folder.errors.full_messages
    else
      flash[:error] = 'Folder Not Found'
    end
    administratable_orgs
    render :partial => "/apps/classroom/utility_folders", :locals => {:org_list => @admin_folder_orgs}
  end

  def admin_folders_copy
    initialize_parameters
    get_org
    if @org
      cnt = 0
      parent_folders(@org).each do |folder|
        new_folder = folder.dup
        folder.folder_mastery_levels.each do |ml|
          new_ml = ml.dup
          new_folder.folder_mastery_levels << new_ml
        end
        @current_organization.folders << new_folder
        cnt += 1
        folder.all_children.each do |chld|
          new_child = chld.dup
          new_child.parent_id = new_folder.id
          @current_organization.folders << new_child
          cnt += 1
          chld.folder_mastery_levels.each do |ml|
            new_ml = ml.dup
            new_child.folder_mastery_levels << new_ml
          end
        end
      end
      flash[:notice] = cnt.to_s + " #{@org.short_name} Folders Transferred"
    else
      flash[:error] = 'Source Organization Not Found'
    end
    administratable_orgs
    render :partial => "/apps/classroom/utility_folders", :locals => {:org_list => @admin_folder_orgs}
  #  render :text => @org.short_name
  end

  def admin_destroy_offering
    initialize_parameters
    if @classroom && @classroom.destroy
      flash[:notice] = 'Offering Destroyed'
    elsif @classroom
      flash[:error] = @classroom.errors.full_messages
    else
      flash[:error] = 'Offering Not Found'
    end
    administratable_orgs
    render :partial => "/apps/classroom/utility_offerings", :locals => {:org_list => @admin_offering_orgs}
  end

  def admin_offering_copy
    initialize_parameters
    get_offering
    if @offering
      @new_offering = @offering.dup
      @new_offering.status = ''
      @new_offering.user_id = @current_user.id
      @new_offering.featured_topic_id = nil
      @new_offering.duplicate_contents(@offering)
      @new_offering.duplicate_referrals(@offering)
      @new_offering.duplicate_ifa(@offering)
      @current_organization.classrooms << @new_offering
      duplicate_offering_folder
      @new_offering.duplicate_periods(@offering)
      @new_offering.duplicate_lus(@offering)
      flash[:notice] = " #{@offering.organization.short_name}: #{@offering.name} Duplicated."
    else
      flash[:error] = 'Source Offering Not Found'
    end
    administratable_orgs
    render :partial => "/apps/classroom/utility_offerings", :locals => {:org_list => @admin_offering_orgs}
  end

  def admin
  end

  def add_classroom
    initialize_parameters
    @classroom = Classroom.new
    @classroom.organization_id = @current_organization.id
    @classroom.user_id = @current_user.id
    @classroom.is_open = true    
    @classroom.course_name = params[:classroom_name]
    subject = SubjectArea.find_by_id(params[:child_subject_id]) rescue nil
    if subject.nil?
     subject = SubjectArea.find_by_id(params[:parent_subject_id]) rescue nil     
    end
    @classroom.subject_area_id = subject.nil? ? nil : subject.id
    ifa_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
    @classroom.act_subject_id = ifa_subject.nil? ? nil : ifa_subject.id
    if @classroom.save
      flash[:notice] = 'Offering Successfully Created.'
      new_name = ""
    else
      flash[:error] = @classroom.errors.full_messages
      new_name = params[:classroom_name]
    end
    ifa_instance_variables
    render :partial => "admin_classrooms", :locals => {:admin => @admin, :parent=> nil, :name =>new_name} 
  end

  def add_lu
    initialize_parameters
    lu = Topic.new
    lu.title = params[:topic_name]
    lu.estimated_start_date = Date.new(params[:start_y].to_i, params[:start_m].to_i, params[:start_d].to_i)   
    lu.estimated_end_date = Date.new(params[:end_y].to_i, params[:end_m].to_i, params[:end_d].to_i) 
    lu.user_id = @current_user.id
    lu.is_open = false
    @classroom.topics << lu
    render :partial => "apps/classroom/offering_lus", :locals => {:admin => @admin, :offering => @classroom}
  end

  
  def show_content
    @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    if params[:folder_id]
      @folder = Folder.find_by_public_id params[:folder_id]
    else
      @folder = nil
    end
    @content = Content.active.find_by_public_id params[:id] rescue nil
    render :layout => false
  end
  
  def identify_parent_subject
    initialize_parameters
    ifa_instance_variables
    if params[:parent_subject_id]
      parent = SubjectArea.find_by_id(params[:parent_subject_id]) rescue nil
    else
      parent=nil
    end
    render :partial => "admin_classrooms", :locals => {:admin => @admin, :parent=> parent, :name => params[:classroom_name]}
  end

  def change_parent_subject
    initialize_parameters
    if params[:parent_subject_id]
      parent = SubjectArea.find_by_id(params[:parent_subject_id]) rescue nil
    else
      parent = @classroom.parent_subject
    end
    ifa_instance_variables
    render :partial => "edit_classroom", :locals => {:admin => @admin, :parent=> parent, :classroom => @classroom, :app=> @app}
  end

  def change_act_subject
    initialize_parameters
    if params[:act_subject_id]
      subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
      @classroom.update_attributes(:act_subject_id => (subject.nil? ? nil : subject.id))
      if @classroom.act_subject.nil?
        @classroom.ifa_disable
      end
    end
    ifa_instance_variables
    render :partial => "edit_classroom", :locals => {:admin => @admin, :parent=> @classroom.parent_subject, :classroom => @classroom, :app=> @app}
  end
  
  def setup_classroom
    initialize_parameters
    ifa_instance_variables
  end
  
  def setup_classroom_lu
    initialize_parameters
      if params[:function] == "Update"  && @topic   
       if @topic.update_attributes(params[:topic])
            flash[:notice] = "Learning Unit Updated"
         else
            flash[:error] = "Learning Unit Not Successfully Updated"
       end
      refresh_lu
      end
  end
  
  def register_classroom
    initialize_parameters
  end

  def offering_homeworks
    initialize_parameters
  end

  def offering_periods
    initialize_parameters
  end

  def offering_lus
    initialize_parameters
  end

  def offering_resources
    initialize_parameters
  end

  def offering_strands
    initialize_parameters
    get_topic_strands(@topic)
  end

  def assign_lu_strand
    initialize_parameters
    if @strand
      @topic.act_standards.include?(@strand) ? @topic.act_standard_topics.for_strand(@strand).destroy_all : (@topic.act_standards << @strand)
    end
    get_topic_strands(@topic)
    render :partial => "/apps/classroom/offering_strands", :locals => {:admin => true,:lu=> @topic}
  end

  def offering_referrals
    initialize_parameters
  end

  def offering_students
    initialize_parameters
  end

  def offering_folders
    initialize_parameters
  end

  def offering_folder_masteries
    initialize_parameters
    get_parent_folders
    get_mastery_levels
  end

  def offering_folder_benchmarks
    initialize_parameters
    if @mastery_level && @strand
      improve = ActBenchType.improvement(@mastery_level.act_master)
      benchmark = ActBenchType.benchmark(@mastery_level.act_master)
      evidence = ActBenchType.evidence(@mastery_level.act_master)
      example = ActBenchType.example(@mastery_level.act_master)
      @benches = benchmark.nil? ? [] : benchmark.act_benches.enabled_for_level_strand(@mastery_level, @strand).student_benchmarks
      @improvements = improve.nil? ? [] : improve.act_benches.enabled_for_level_strand(@mastery_level, @strand).student_benchmarks
      @evidences = evidence.nil? ? [] : evidence.act_benches.enabled_for_level_strand(@mastery_level, @strand).student_benchmarks
      @examples = improve.nil? ? [] : example.act_benches.enabled_for_level_strand(@mastery_level, @strand).student_benchmarks
    end
  end

  def offering_folder_mastery_assign
    initialize_parameters
    mastery_level = ActScoreRange.find_by_id(params[:mastery_level_id])
    if @folder.act_score_ranges.include?(mastery_level)
      @folder.folder_mastery_levels.for_level(mastery_level).destroy_all
    else
      @folder.act_score_ranges << mastery_level
    end
    get_parent_folders
    get_mastery_levels
    render :partial => "apps/classroom/offering_folder_masteries"
  end

  def offering_views
    initialize_parameters
  end

  def offering_folder_views
    initialize_parameters
  end
  
  def offering_surveys
    initialize_parameters
    @audience = CoopApp.classroom.tlt_survey_audiences.student.first
  end

  def offering_folder_setup
    initialize_parameters
  end
      
  def offering_resource_sequence
    initialize_parameters
     if @resource
      resources = (@topic.nil? ? @classroom.classroom_contents : (@folder.nil? ? @topic.topic_contents.unfoldered : @topic.topic_contents.for_folder(@folder))).sort_by{|cc| cc.position} rescue []
      resources.each_with_index do|cc,idx|
      if cc.content_id == @resource.id
        if params[:direction]=="up" && idx>0
          base_position = cc.position
          cc.update_attributes(:position => resources[idx-1].position)
          resources[idx-1].update_attributes(:position => base_position)
        end
        if params[:direction]=="down" && (idx+1)<resources.size
          base_position = cc.position
          cc.update_attributes(:position => resources[idx+1].position)
          resources[idx+1].update_attributes(:position => base_position)
        end  
        if params[:direction]=="top"
          cc.update_attributes(:position => 1)
          jdx = 0
          until jdx == idx
           resources[jdx].update_attributes(:position => resources[jdx].position + 1)
           jdx += 1
          end
        end
      end
    end
    @topic.nil? ? @classroom.sequence_resources : @topic.sequence_resources(@folder)
   end
    get_pool_filters(params[:pool_class].to_i)
    get_pool_resources(params[:pool_class].to_i, params[:pool_filter].to_i)
    render :partial => "apps/classroom/offering_resources", :locals => {:admin => @admin, :copy_lu=>@copy_lu, :offering => @classroom, :app=> @app, :lu=>@topic, :pool_class => params[:pool_class].to_i, :pool_filter => params[:pool_filter].to_i, :filters=> @filters, :pool=>@resource_pool, :header=>@header_line} 
 end 

  def add_remove_resource
    initialize_parameters
    if @resource && @classroom    
      if @topic.nil?
        if @classroom.contents.include?(@resource) 
          @classroom.contents.delete @resource
          @classroom.sequence_resources
        else  
          @classroom.contents << @resource
        end
      else
        if @topic.contents.include?(@resource) 
          folders = @topic.folders_for_resource(@resource)
          if @topic.featured_content == @resource.id 
            remove_featured_resource(@topic)
          end
          @topic.contents.delete @resource
        else  
          tc = TopicContent.new
          tc.content_id = @resource.id
          tc.folder_id = (params[:folder_id] && params[:folder_id].to_i > 0) ? params[:folder_id].to_i : nil
          @topic.topic_contents << tc
        end         
        @topic.sequence_all_resource_folders
       end
    end
    get_pool_filters(params[:pool_class].to_i)
    get_pool_resources(params[:pool_class].to_i, params[:pool_filter].to_i)
    render :partial => "apps/classroom/offering_resources", :locals => {:admin => @admin, :copy_lu=>@copy_lu, :offering => @classroom, :app=> @app, :lu=>@topic, :pool_class => params[:pool_class].to_i, :pool_filter => params[:pool_filter].to_i, :filters=> @filters, :pool=>@resource_pool, :header=>@header_line}
  end
  
  def copy_lu_resources
    initialize_parameters
    if Topic.find_by_id(params[:copy_lu_id]) && @topic
      Topic.find_by_id(params[:copy_lu_id]).topic_contents.compact.each do |tc|
        unless @topic.contents.include?(tc.content)
          new_tc = TopicContent.new
          new_tc.content_id = tc.content_id
          new_tc.folder_id = (tc.folder && @topic.resource_folders.include?( tc.folder)) ? tc.folder_id : nil
          new_tc.position = tc.position
          @topic.topic_contents<<new_tc 
        end
      end
      @topic.sequence_all_resource_folders      
    end
    get_pool_filters(params[:pool_class].to_i)
    get_pool_resources(params[:pool_class].to_i, params[:pool_filter].to_i)  
    render :partial => "apps/classroom/offering_resources", :locals => {:admin => @admin, :copy_lu=>@copy_lu, :offering => @classroom, :app=> @app, :lu=>@topic, :pool_class => params[:pool_class].to_i, :pool_filter => params[:pool_filter].to_i, :filters=> @filters, :pool=>@resource_pool, :header=>@header_line}
  end
    
  def resource_pool
    initialize_parameters
    get_pool_filters(params[:pool_class].to_i)
    get_pool_resources(params[:pool_class].to_i, params[:pool_filter].to_i)  
    render :partial => "apps/classroom/offering_resources", :locals => {:admin => @admin, :copy_lu=>@copy_lu, :offering => @classroom, :app=> @app, :lu=>@topic, :pool_class => params[:pool_class].to_i, :pool_filter => params[:pool_filter].to_i, :filters=> @filters, :pool=>@resource_pool, :header=>@header_line}
  end

  def toggle_lu_featured_resource
    initialize_parameters
    if @resource && @topic
      @topic.featured_content == @resource.id ? remove_featured_resource(@topic) : assign_featured_resource(@topic, @resource)
    end
    refresh_lu
    get_pool_filters(params[:pool_class].to_i)
    get_pool_resources(params[:pool_class].to_i, params[:pool_filter].to_i) 
    render :partial => "apps/classroom/offering_resources", :locals => {:admin => @admin, :copy_lu=>@copy_lu, :offering => @classroom, :app=>@app, :lu=>@topic, :pool_class => params[:pool_class].to_i, :pool_filter => params[:pool_filter].to_i, :filters=> @filters, :pool=>@resource_pool, :header=>@header_line}   
  end

  def lu_resource_folder
    initialize_parameters

    if @resource && @topic
        add_resource_to_lu_folder(@resource, @topic, @folder) 
        @topic.sequence_all_resource_folders
    end
    refresh_lu
    get_pool_filters(params[:pool_class].to_i)
    get_pool_resources(params[:pool_class].to_i, params[:pool_filter].to_i) 
    render :partial => "apps/classroom/offering_resources", :locals => {:admin => @admin, :copy_lu=>@copy_lu, :offering => @classroom, :app=>@app, :lu=>@topic, :pool_class => params[:pool_class].to_i, :pool_filter => params[:pool_filter].to_i, :filters=> @filters, :pool=>@resource_pool, :header=>@header_line}   
  end

  def add_remove_referral
    initialize_parameters
    if @topic && @classroom    
      if @classroom.classroom_referrals.for_topic(@topic).empty?
          referral = ClassroomReferral.new
          referral.topic_id = @topic.id    
          @classroom.classroom_referrals << referral
      else  
        @classroom.classroom_referrals.for_topic(@topic).destroy_all
      end
      refresh_classroom
    end
    render :partial => "apps/classroom/offering_referrals", :locals => {:admin => @admin, :offering => @classroom}
  end
  
  def self_register_student
    initialize_parameters
    @period = @classroom.classroom_periods.first
    if @classroom.classroom_periods.size > 1 && params[:registration][:period_id] != ""
      @period = ClassroomPeriod.find_by_public_id(params[:period_id]) rescue nil
      unless @period
        @period = ClassroomPeriod.find_by_id(params[:registration][:period_id]) rescue nil
      end
    end
    if @period && @student
      if (@classroom.open? || params[:registration][:key]==@classroom.registration_key)
        @student.add_to_period(@period)
        @student.set_classroom_favorite(@period.classroom, "add")
      end
    end
    redirect_to offering_view_path(:organization_id => @current_organization, :id => @classroom)
  #  render :partial => "apps/classroom/register_student", :locals=> {:classroom => @classroom}
  end
  
  def self_unregister_student
    initialize_parameters
    period = @classroom.period_for_student(@student)
    if period && @student
      remove_student_from_period(@student, period)
    end
    render :partial => "apps/classroom/register_student", :locals=> {:classroom => @classroom}
  end
  
  def edit_classroom
    initialize_parameters
    new_name = params[:classroom_name] == "" ? @classroom.course_name : params[:classroom_name]
    parent_subject = SubjectArea.find_by_id(params[:parent_subject_id]) rescue nil
    subject = SubjectArea.find_by_id(params[:child_subject_id]) rescue nil
    if subject.nil? 
     subject = !(parent_subject == @classroom.subject_area) && !parent_subject.nil? ? parent_subject : @classroom.subject_area
    end
    if @classroom.update_attributes(:course_name => new_name, :subject_area_id => subject.id)
      flash[:notice] = 'Classroom Updated.'
    else 
     flash[:error] = @classroom.errors.full_messages       
    end    
    refresh_classroom
    ifa_instance_variables
    render :partial => "edit_classroom", :locals => {:admin => @admin, :parent=> @classroom.parent_subject, :parent_reset => false, :classroom => @classroom, :name=> @classroom.course_name} 
  end
  
  def change_classroom_name
    initialize_parameters
    new_name = params[:classroom_name] == "" ? @classroom.course_name : params[:classroom_name]
    if @classroom.update_attributes(:course_name => new_name)
      flash[:notice] = 'Classroom Name Updated.'
    else 
     flash[:error] = @classroom.errors.full_messages       
    end    
    refresh_classroom
    ifa_instance_variables
    render :partial => "edit_classroom", :locals => {:admin => @admin, :parent=> @classroom.parent_subject, :classroom => @classroom, :app=>@app} 
  end
  
  def change_classroom_subject
    initialize_parameters
    parent_subject = SubjectArea.find_by_id(params[:parent_subject_id]) rescue nil
    subject = SubjectArea.find_by_id(params[:child_subject_id]) rescue nil
    if subject.nil? 
     subject = !(parent_subject == @classroom.subject_area) && !parent_subject.nil? ? parent_subject : @classroom.subject_area
    end
    if @classroom.update_attributes(:subject_area_id => subject.id)
      flash[:notice] = 'Subject Updated'
    else 
     flash[:error] = @classroom.errors.full_messages       
    end    
    refresh_classroom
    ifa_instance_variables
    render :partial => "edit_classroom", :locals => {:admin => @admin, :parent=> @classroom.parent_subject, :classroom => @classroom, :app=>@app} 
  end

  def add_period
    initialize_parameters
    period = ClassroomPeriod.new
    period.classroom_id = @classroom.id
    period.name = params[:period_name]
    period.start_date = Date.new(params[:start_yr].to_i, params[:start_mth].to_i, params[:start_day].to_i)
    period.week_duration = params[:duration].to_i rescue nil 
    if period.save
      flash[:notice] = @classroom.course_name + ' Period Created'
    else 
     flash[:error] = period.errors.full_messages       
    end 
    refresh_classroom
    render :partial => "offering_periods", :locals => {:admin => @admin, :offering => @classroom} 
  end

  def manage_period_teachers
    initialize_parameters
    if @teacher && @period
      if @period.teachers.include?(@teacher) 
        @period.classroom_period_users.for_teacher(@teacher).each do |per|
          per.destroy
        end       
         unless @teacher.teacher_of_classroom?(@period.classroom)
           @teacher.set_classroom_favorite(@period.classroom, "remove")
        end
      else
        period_user = ClassroomPeriodUser.new
        period_user.user_id = @teacher.id
        period_user.is_teacher = true
        period_user.is_student = false
        @period.classroom_period_users<<period_user
        @teacher.set_classroom_favorite(@period.classroom, "add")
      end
    end
    refresh_period
    render :partial => "offering_periods", :locals => {:admin => @admin, :offering => @classroom} 
  end

  def add_teacher
    initialize_parameters
    if @teacher && @period
      assign_teacher_to_period(@teacher, @period)
    end
    refresh_period
    render :partial => "list_periods", :locals => {:admin => @admin}
  end

  def remove_teacher
    initialize_parameters
    if @teacher && @period
      remove_teacher_from_period(@teacher, @period)
    end
    refresh_period
    render :partial => "list_periods", :locals => {:admin => @admin}
  end

  def manage_teacher
    initialize_parameters
    render :partial => "manage_teachers", :locals => {:admin => @admin, :app => @app, :teacher=>@teacher, :subject=> nil}
  end

  def assign_for_subject
    initialize_parameters
    render :partial => "manage_teachers", :locals => {:admin => @admin, :app => @app, :teacher=>@teacher, :subject=> @subject_area}
  end

  def assign_period_teacher_1
    initialize_parameters
    if @teacher && @period
      @period.teacher?(@teacher) ? remove_teacher_from_period(@teacher, @period) : assign_teacher_to_period(@teacher, @period)
    end
    subject = @period ? @period.classroom.parent_subject : nil
    refresh_period
    render :partial => "manage_teachers", :locals => {:admin => @admin, :app => @app, :teacher=>@teacher, :subject => @subject_area}
  end

  def assign_period_teacher_2
    initialize_parameters
    if @teacher && @period
      @period.teacher?(@teacher) ? remove_teacher_from_period(@teacher, @period) : assign_teacher_to_period(@teacher, @period)
    end
    refresh_period
    render :partial => "show_offering_periods", :locals => {:admin => @admin, :classroom => @period.classroom} 
  end
  
  def select_teacher
    initialize_parameters
    render :partial => "select_period"
  end

  def select_period
    initialize_parameters
    render :partial => "select_period"
  end

  def manage_period_students
    initialize_parameters
  end

  def subject_offerings
    initialize_parameters
    @subject_area = @subject_area ? @subject_area : nil
    @folder = @folder ? @folder : nil
  end

  def list_students
    initialize_parameters
  end

  def show_lu_resources
    initialize_parameters
    if !@folder.nil? && !@topic.nil?
      @folder.increment_views
      @mastery_levels = @folder.mastery_levels
      @strands = @topic.act_standards
    end
  end

  def list_folder_resources
    initialize_parameters
    render :partial => "list_lu_folder_resources", :locals => {:lu => @topic, :folder => @folder}
  end
   
   def add_remove_student
    initialize_parameters
    if @period.students.include?(@student)
      remove_student_from_period(@student, @period)
    else
      @student.add_to_period(@period)
      @student.set_classroom_favorite(@period.classroom, "add")
    end
    refresh_period
    render :partial => "manage_period_students", :locals=> {:period => @period, :return_action => params[:redirect_act]}
  end

  def remove_all_students
    initialize_parameters
    if @period
      students = @period.students.compact
      @period.classroom_period_users.students.destroy_all 
      students.each do |stud|
        unless stud.user_of_classroom?(@period.classroom)
          stud.set_classroom_favorite(@period.classroom, "remove")
        end
      end
    end
    refresh_period
    redirect_to :action => params[:redirect_act], :organization_id => @current_organization,  :classroom_id => @period.classroom
  end

  def edit_period
    initialize_parameters
    start_date = Date.new(params[:start_yr].to_i, params[:start_mth].to_i, params[:start_day].to_i)
    if @period.update_attributes(:name => params[:period_name], :week_duration => params[:duration].to_i, :start_date => start_date )
      flash[:notice] = @classroom.course_name + ' Period Update'
    else 
     flash[:error] = period.errors.full_messages       
    end 
    refresh_classroom
    render :partial => "offering_periods", :locals => {:admin => @admin, :offering => @classroom}  
  end

  def toggle_active
    initialize_parameters
    if @classroom
      @classroom.status == "active" ? @classroom.update_attributes(:status => nil) : @classroom.update_attributes(:status => "active")
    end
    refresh_classroom
    ifa_instance_variables
    render :partial => "edit_classroom", :locals => {:admin => @admin, :app => @app, :parent=> @classroom.parent_subject, :classroom => @classroom} 
  end

 def destroy_classroom
    initialize_parameters
    if @classroom
      @classroom.destroy
    end
   redirect_to self.send(@current_application.link_path, {:organization_id => @current_organization})
 end

 def destroy_period
    initialize_parameters
    if @period
      @period.destroy
    end
    refresh_classroom
    render :partial => "offering_periods", :locals => {:admin => @admin, :offering => @classroom}  
 end

  def toggle_lu_options
    initialize_parameters
    if @topic && @topic.classroom
      if params[:option]=="discussion"
        @topic.update_attributes(:is_open => !@topic.is_open)
      end
      if params[:option]=="feature"
        @topic.classroom.update_attributes(:featured_topic_id => @topic.id)
      end
      if params[:option]=="notify"
        @topic.update_attributes(:should_notify => !@topic.should_notify)
      end    
      if params[:option]=="suspend"
        @topic.discussions.each do |disc|
          disc.suspend!(:user => @current_user)
        end
      end
      if params[:option]=="d_clear"
        @topic.discussions.destroy_all
      end
    end
    refresh_lu
    render :partial => "lu_options", :locals => {:lu=> @topic}
  end

  def destroy_lu
    initialize_parameters
    classroom = @topic.classroom
    @topic.destroy
    redirect_to offering_setup_path(:organization_id => @current_organization,  :classroom_id => classroom)
  end

  def change_lu_dates
    initialize_parameters
    new_start_date = Date.new(params[:start_y].to_i, params[:start_m].to_i, params[:start_d].to_i)   
    new_end_date = Date.new(params[:end_y].to_i, params[:end_m].to_i, params[:end_d].to_i) 
    @topic.update_attributes(:estimated_start_date => new_start_date, :estimated_end_date => new_end_date)
    refresh_lu
    render :partial => "edit_classroom_lu", :locals => {:admin => @admin, :lu=> @topic} 
  end
  
###   Classroom functions below

 
  def survey_classroom_schedule
    initialize_parameters
    @classroom.classroom_periods.collect{|p| p.survey_schedules.active}.flatten.each do|schedule|
      unless schedule.schedule_end.nil? || schedule.schedule_end >= Date.today
        schedule.de_activate
      end
    end
    refresh_classroom
  end 

  def survey_classroom_results
    initialize_parameters
  end 

  def question_aggregation
    initialize_parameters
    @question = TltSurveyQuestion.find_by_public_id(params[:question_id])rescue nil
    @schedule = SurveySchedule.find_by_public_id(params[:schedule_id]) rescue nil
  end 

  def period_survey_activate
    initialize_parameters
    schedule_survey_app(@period, @period.classroom.organization, @period.classroom.subject_area_id, @audience, @type, nil, params[:duration],@type.notify_default(@audience), @type.anon_default(@audience))
    render :partial => "survey_classroom_schedule", :locals=> {:classroom => @period.classroom, :audience=>@audience}
  end
 
   def period_survey_deactivate
    initialize_parameters
    @period.survey_schedules.each do |s|
      s.de_activate
     end
    render :partial => "survey_classroom_schedule", :locals=> {:classroom => @period.classroom,  :audience=>@audience}
  end 

  def delete_homework
    initialize_parameters
    if @homework
      @homework.update_attributes(:is_deleted=>true) 
    end 
    render :partial => "apps/classroom/offering_homeworks", :locals => {:offering => @classroom} 
  end

  def offering_options   
    initialize_parameters
    if params[:option] == "homework"
      @classroom.update_attributes(:homework_option =>!@classroom.homework_option)
    end
    if params[:option] == "viewing"
      if @classroom.open?
        @classroom.update_attributes(:registration_key=>Classroom.new_registration_key)
      end
      @classroom.update_attributes(:is_open =>!@classroom.is_open)
    end
    if params[:option] == "ifa"
      @classroom.ifa_classroom_option ? @classroom.ifa_disable : @classroom.ifa_enable
    end
    if params[:option] == "ifa_notify" && @classroom.ifa_classroom_option
      @classroom.ifa_classroom_option.update_attributes(:is_ifa_notify =>!@classroom.ifa_classroom_option.is_ifa_notify)
    end
    if params[:option] == "ifa_finalize" && @classroom.ifa_classroom_option
      @classroom.ifa_classroom_option.update_attributes(:is_ifa_auto_finalize =>!@classroom.ifa_classroom_option.is_ifa_auto_finalize)
    end
    if params[:option] == "retake" && @classroom.ifa_classroom_option
      if params[:days]
        repeat_days = params[:days].to_i >= 0 ? params[:days].to_i : 0
        @classroom.ifa_classroom_option.update_attributes(:days_til_repeat => repeat_days)
      end
    end
    if params[:option] == "precision_prep"
      @classroom.update_attributes(:is_prep =>!@classroom.is_prep)
    end
    refresh_classroom
    ifa_instance_variables
    render :partial => "offering_options", :locals=>{:offering => @classroom}
  end

   private

  def classroom_allowed?
    @current_application = CoopApp.classroom
    current_app_enabled_for_current_org?
  end


  def initialize_parameters 
    @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    if params[:app_id]
      @app = CoopApp.find_by_id(params[:app_id]) rescue nil
    end
    unless @app
      @app = CoopApp.classroom
    end
    
    @admin = @current_user.classroom_admin_for_org?(@current_organization)
    @self_admin = @current_user.teacher_for_org?(@current_organization)

    if params[:classroom_id]
      @classroom =Classroom.find_by_public_id(params[:classroom_id])  rescue nil
    end

    if params[:topic_id]
      @topic =Topic.find_by_public_id(params[:topic_id])  rescue nil
    else
      @topic = nil
    end

    if params[:subject_area_id]
      @subject_area = SubjectArea.find_by_id(params[:subject_area_id]) rescue nil
    end

    if params[:resource_id]
      @resource = Content.find_by_public_id(params[:resource_id]) rescue nil
    end

    if params[:content_id]
      @content = Content.find_by_public_id(params[:content_id]) rescue nil
    end
        
    if params[:teacher_id]
      @teacher = User.find_by_id(params[:teacher_id]) rescue nil
    end

    if params[:audience_id]
      @audience = TltSurveyAudience.find_by_public_id(params[:audience_id]) rescue nil
    end

    if params[:type_id]
      @type = TltSurveyType.find_by_public_id(params[:type_id]) rescue nil
    end


    if params[:period_id]
      @period = ClassroomPeriod.find_by_public_id(params[:period_id]) rescue nil
      unless @period
        @period = ClassroomPeriod.find_by_id(params[:period_id]) rescue nil
      end
    end

    if params[:homework_id]
      @homework = Homework.find_by_public_id(params[:homework_id]) rescue nil
      unless @homework
        @homework = Homework.find_by_id(params[:homework_id]) rescue nil
      end
    end
    
    if params[:student_id]
      @student = User.find_by_public_id(params[:student_id]) rescue nil
      unless @student
        @student = User.find_by_id(params[:student_id]) rescue nil
      end
    end
    
    if params[:folder_id]
      @folder = Folder.find_by_id(params[:folder_id]) rescue nil
    end

    if params[:act_standard_id]
      @strand = ActStandard.find_by_id(params[:act_standard_id])
    end
    if params[:act_score_range_id]
      @mastery_level = ActScoreRange.find_by_id(params[:act_score_range_id])
    end
  end

  def refresh_classroom 
    if params[:classroom_id]
      @classroom =Classroom.find_by_public_id(params[:classroom_id])  rescue nil
    end
  end

  def refresh_lu 
    if params[:topic_id]
      @topic =Topic.find_by_public_id(params[:topic_id])  rescue nil
    end
  end

  def refresh_period
    if params[:period_id]
      @period = ClassroomPeriod.find_by_public_id(params[:period_id]) rescue nil
      unless @period
        @period = ClassroomPeriod.find_by_id(params[:period_id]) rescue nil
      end
    end
  end

  def assign_teacher_to_period(user, per)
    if user && per
      unless per.users.include?(user) 
        period_user = ClassroomPeriodUser.new
        period_user.user_id = user.id
        period_user.is_teacher = true
        period_user.is_student = false
        per.classroom_period_users<<period_user
      end
        user.set_classroom_favorite(per.classroom, "add")
    end    
  end

  def remove_teacher_from_period(user, per)
    if user && per
      per.classroom_period_users.for_teacher(user).each do |p|
        p.destroy
      end
      unless user.user_of_classroom?(per.classroom)
        user.set_classroom_favorite(per.classroom, "remove")
      end
    end    
  end

  def add_student_to_period(stud, per)
    if stud && per
      unless per.users.include?(stud) 
        period_user = ClassroomPeriodUser.new
        period_user.user_id = stud.id
        period_user.is_teacher = false
        period_user.is_student = true
        per.classroom_period_users<<period_user
      end
        stud.set_classroom_favorite(per.classroom, "add")
    end    
  end

  def remove_student_from_period(stud, per)
    if stud && per
      per.classroom_period_users.for_student(stud).each do |p|
        p.destroy
      end
      unless stud.user_of_classroom?(per.classroom)
        stud.set_classroom_favorite(per.classroom, "remove")
      end
    end    
  end

  def get_pool_filters(pool_class)
    allowed_types
    if pool_class == 0
      @filters = @current_user.favorite_resources.compact.select{|r| (r.viewable_by_user?(@current_user))}.collect{|r| r.content_object_type.content_object_type_group}.compact.uniq.select{|t| @allowed_types.include?(t.id)}.sort_by{|t| t.name}.collect{|t| [t.name, t.id]}
    elsif pool_class == 1
      @filters = @current_user.favorite_classrooms.compact.uniq.sort_by{|o| o.course_name}.collect{|c| [c.organization.medium_name+": "+ c.course_name, c.id]}
    elsif pool_class == 2
      @filters = @current_user.favorite_organizations.compact.uniq.sort_by{|o| o.name}.collect{|o| [o.medium_name, o.id]}
    elsif pool_class == 3
      @filters = @current_user.colleagues.compact.uniq.sort_by{|u| u.last_name}.collect{|t| [t.last_name_first, t.id]}
    elsif pool_class == 4
      @filters = @current_user.favorite_classrooms.compact.uniq.select{|o| o.organization}.sort_by{|o| o.organization.short_name}.collect{|o| o.topics}.flatten.collect{|t| [" (" + t.classroom.organization.short_name + ") " + t.classroom.course_name + ": " + t.title, t.id]}
    elsif pool_class == 5
      @filters = ActStandard.strands_for_subject(@classroom.act_subject).collect{|s| [(s.standard.abbrev + ' ' + s.subject_area.name  + ' | ' + s.name), s.id]}
    else
      @filters = []
    end   
  end

  def get_pool_resources(pool_class, pool_filter)
    allowed_types
    @copy_lu = nil
    if pool_filter && pool_class == 0
      resource_type = ContentObjectTypeGroup.find_by_id(pool_filter) rescue nil
      @resource_pool = @current_user.favorite_resources.compact.select{|r| r.content_object_type && r.content_object_type.content_object_type_group_id == pool_filter && @allowed_types.include?(r.content_object_type.content_object_type_group_id)}   
      @resource_pool-= @topic.nil? ? @classroom.contents.active.compact : @topic.contents.active.compact
      @header_line = resource_type.nil? ? "" : (@current_user.last_name + " " + resource_type.name)
    elsif pool_filter && pool_class == 1
      offering = Classroom.find_by_id(pool_filter) rescue nil
      @resource_pool = offering.nil? ? [] : offering.contents.active.compact.select{|r| r.content_object_type && @allowed_types.include?(r.content_object_type.content_object_type_group_id)}
      @resource_pool-= @topic.nil? ? @classroom.contents.active.compact : @topic.contents.active.compact
      @header_line = offering.nil? ? "" : (offering.organization ? (offering.organization.medium_name + ": " + offering.course_name) :  offering.course_name)
    elsif pool_filter && pool_class == 2
      org = Organization.find_by_id(pool_filter) rescue nil
      @resource_pool = org.nil? ? [] : org.contents.active.compact.select{|r| r.content_object_type && @allowed_types.include?(r.content_object_type.content_object_type_group_id)}  
      @resource_pool-= @topic.nil? ? @classroom.contents.active.compact : @topic.contents.active.compact
      @header_line = org.nil? ? "" : org.medium_name
    elsif pool_filter && pool_class == 3
      user = User.find_by_id(pool_filter) rescue nil
      @resource_pool = user.nil? ? [] : user.favorite_resources.compact.select{|r| r.content_object_type && @allowed_types.include?(r.content_object_type.content_object_type_group_id)}   
      @resource_pool-= @topic.nil? ? @classroom.contents.active.compact : @topic.contents.active.compact
      @header_line = user.nil? ? "" : user.full_name
    elsif pool_filter && pool_class == 4
      fav_lu = Topic.find_by_id(pool_filter) rescue nil
      @resource_pool = fav_lu.nil? ? [] : fav_lu.contents.active.compact.select{|r| r.content_object_type && @allowed_types.include?(r.content_object_type.content_object_type_group_id)}
      @resource_pool-= @topic.nil? ? @classroom.contents.active.compact : @topic.contents.active.compact
      @copy_lu = (!fav_lu.nil? && fav_lu.classroom.organization_id == @current_organization.id) ? fav_lu : nil
      @header_line = fav_lu.nil? ? "" : (fav_lu.title + (fav_lu.classroom.organization ? (" (" + fav_lu.classroom.organization.short_name + ")"): ""))
    elsif pool_filter && pool_class == 5
      strand = ActStandard.find_by_id(pool_filter)
      if !strand.nil?
        @resource_pool = strand.contents.active.compact.select{|r| r.content_object_type && @allowed_types.include?(r.content_object_type.content_object_type_group_id)}
        @resource_pool-= @topic.nil? ? @classroom.contents.active.compact : @topic.contents.active.compact
        @header_line = strand.name
      else
        @resource_pool = []
        @header_line = ""
      end
    else
      @resource_pool = []
      @header_line = ""
    end
    @resource_pool = @resource_pool.select{|r| r.usable_by_org?(@classroom.organization) && r.viewable_by_user?(@current_user)}   
  end
  
  def allowed_types
    @allowed_types = @topic.nil? ? [2,5,7,8] : [2,3,4,5,7,8]
  end

  def add_resource_to_lu_folder(rsrc, lu, folder) 
    if lu.topic_contents.for_resource(rsrc).size == 1
      unless folder.nil?
        lu.topic_contents.for_resource(rsrc).first.update_attributes(:folder_id => folder.id)
      else
        lu.topic_contents.for_resource(rsrc).first.update_attributes(:folder_id => nil)
      end
    end
  end

  def remove_resource_from_lu_folder(rsrc, lu, folder) 
    folder.topic_contents.for_topic.each do |tc|
      if tc.content == rsrc
        tc.destroy
      end
    end
  end
 
  def assign_featured_resource(lu, rsrc)
    lu.update_attributes(:featured_content=> rsrc.id)
  end 
 
  def remove_featured_resource(lu)
    lu.update_attributes(:featured_content=> nil)
  end

  def get_topic_strands(topic)
    @remove_strands = topic.act_standards.sort_by{|f| [f.act_subject.name, f.act_master.abbrev, f.abbrev]}
    @add_strands = @current_organization.knowledge_strands.sort_by{|f| [f.act_subject.name, f.act_master.abbrev, f.abbrev]} - @remove_strands
  end

  def get_folder
    @folder = Folder.find_by_id(params[:folder_id]) rescue nil
  end

  def get_org
    @org = Organization.find_by_id(params[:org_id]) rescue nil
  end

  def get_offering
    @offering = Classroom.find_by_id(params[:offering_id]) rescue nil
  end

  def get_mastery_levels
    @mastery_levels = @current_organization.ifa_standards.collect{|m| m.act_score_ranges.no_na}.flatten.sort_by{|sr| [sr.act_master.abbrev,sr.act_subject.name, sr.lower_score]}
  end

  def get_parent_folders
    @parent_folders = @current_organization.folders.for_app(@current_application).all_parents.sort_by{|f| f.name.upcase}
  end

  def administratable_orgs
    @admin_orgs = @current_user.app_admin_orgs(@current_application).select{|o| o != @current_organization}
  #  @admin_orgs = @current_user.app_admin_orgs(@current_application)
    @admin_folder_orgs = @admin_orgs.select{|o| !o.folders.empty?}
    @admin_offering_orgs = @admin_orgs.select{|o| !o.classrooms.empty?}
  end

  def parent_folders(org)
    org.folders.select{|f| f.parent?}
  end

  def duplicate_offering_folder
    if @offering.folder
      @new_offering.folder = @offering.folder.copy_to_org(@current_organization)
      orig_position = @offering.folder.folder_positions.org_scope.first rescue nil
      new_position = FolderPosition.new
      new_position.scope_id = @current_organization.id
      new_position.scope_type = @current_organization.class.to_s
      new_position.position = orig_position.nil? ? 1 : orig_position.position
      new_position.is_hidden = orig_position.nil? ? false : orig_position.is_hidden
      @new_offering.folder.folder_positions << new_position
    end
  end
  def ifa_instance_variables
    @ifa_provider = @current_organization.app_enabled?(CoopApp.ifa) ?  @current_organization.app_provider(CoopApp.ifa) : nil
    @ifa_app_name = @current_organization.app_enabled?(CoopApp.ifa) ?  CoopApp.ifa.app_name(:provider=>@ifa_provider) : nil
    @ifa_subjects = @current_organization.app_enabled?(CoopApp.ifa) ? ([['-na-', 0]] + ActSubject.active.map{|s| [s.name, s.id]}) : []
  end
end
