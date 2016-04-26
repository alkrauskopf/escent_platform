class Site::SiteController < Site::ApplicationController

  helper :all # include all helpers, all the time  
  layout "site", :except =>[ :summarize_org_resources, :summarize_org_subject_offerings, :summarize_org_app, :assign_topic_resource_view, :create_new_topic, :edit_topic, :topic_assess, :list_topic_resources, :assign_classroom_resource, :assign_classroom_resource_view, :list_classroom_referrals, :list_classroom_topics, :assign_classroom_referral_links, :assign_classroom_people]

  before_filter :find_featured_topic, :only => [:index, :more_topic, :add_comment, :update_index, :featured_content, :home_users, :related_content, :related_content_list, :assign_classroom_referrals, :assign_classroom_people, :assign_classroom_resource, :create_or_edit_topic, :create_new_topic, :show_content, :show_share_content, :show_result_content, :add_star_rating_to_content, :static_classroom, :manage_topic, :assign_classroom_general]
  protect_from_forgery :except => [:add_star_rating_to_content, :related_content_list]

  before_filter :clear_notification
  
  def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end

  def static_organization
    @current_organization.increment_views
    unless @current_organization.default?
    initialize_std_parameters
    else
      redirect_to  :controller => "//fsn", :action => "index"
    end
  end
  
  def static_resource
    
    initialize_std_parameters
    if params[:id]
      @content = Content.find_by_public_id(params[:id])
    else
      @content = @current_organization.contents.first
    end

    
    @content_topics = []
    if @content
      @mastery_level = @content.act_score_ranges.for_standard(@current_standard).first rescue nil
      @strands = @content.act_standards.for_standard(@current_standard) rescue nil
      @discussions = @content.discussions.active.parent_id_blank(:order_by =>  "created_at DESC")
      @content_topics = @content.topics.active
      @current_subject = @content.act_subject rescue nil
    else
      @discussions = []
    end    
    @content_org = Organization.find_by_id(@content.organization_id)
    if @content_org.nil?
      @content_org = Organization.ep_default.first
    end
  end

  def static_classroom
    @current_application = CoopApp.classroom
    current_app_enabled_for_current_org?
    initialize_site_parameters
    initialize_std_parameters 
    @classroom = params[:id] ? Classroom.find_by_public_id(params[:id]) : @current_organization.classrooms.active.first 
    @classroom.increment_views   
    if @current_user
      @clsrm_leaders = @current_user.student_of_classroom?(@classroom) ? @classroom.teachers_for_student(@current_user) : @classroom.leaders
    else
      @clsrm_leaders = @classroom.leaders
    end
    @topics_list = @classroom.topics.sort{ |a,b| a.estimated_start_date <=> b.estimated_start_date }
    @homeworks_list = @classroom.homeworks.active
    @sms_topics = []

    unless @current_user.nil? 
      @teacher_homeworks = @homeworks_list.select{|h|h.teacher_id == @current_user.id}
      @teacher_assessments = @classroom.act_submissions.select{|s| (s.teacher_id == @current_user.id && !s.is_final)}

# get student sms for classroom

      if @current_organization.ifa_org_option
        @latest_dashboard = @current_user.ifa_dashboards.for_subject_since(@classroom.act_subject, @school_options.begin_school_year).last rescue nil
        teacher_fav_topics = []
        @classroom.leaders.each do |l|
          teacher_fav_topics += l.favorite_classrooms.collect{|c| c.topics}.flatten 
        end
       @sms_topics = teacher_fav_topics.select{|t| t.act_score_range.for_standard(@current_standard).first.upper_score >= @student_sms_score && t.act_score_range.for_standard(@current_standard).first.lower_score <= @student_sms_score} rescue nil
      end
    
    end
    if @current_topic
      @discussions = @current_topic.discussions.active.parent_id_blank(:order_by =>  "created_at DESC")
    else
      @discussions = []
    end    
  rescue
    redirect_to :action => :static_organization
  end

  def assign_classroom_people
    @classroom = Classroom.find_by_public_id(params[:classroom_id])
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    @letter_group = params[:letter] rescue nil
  end

  def classroom_authorization_add_remove
    @classroom = Classroom.find_by_public_id(params[:classroom_id])
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    @letter_group = params[:letter]
    classroom_auth = params[:auth_level]
    person = User.find_by_public_id(params[:participant_id]) rescue nil
    authorization_level = AuthorizationLevel.first(:include => :applicable_scopes, :conditions => ["authorization_levels.name = ? AND applicable_scopes.name = ?", classroom_auth, "Classroom"])
    if (person.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(@classroom, @classroom.class.to_s, authorization_level))
        person.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(@classroom, @classroom.class.to_s, authorization_level).destroy
     else
        person.authorizations.create :authorization_level => authorization_level, :scope => @classroom
        person.add_as_favorite_to(@classroom) unless person.has_authorization_level_for?(@classoom, "favorite")
#        Notifier.deliver_classroom_authorization(:user => person, :admin => @current_user, :classroom => @classroom, :current_organization => @current_organization, :authorization_level => authorization_level, :fsn_host => request.host_with_port)          
    end
     render :partial => "classroom_assign_authorizations"   
  end


  def classroom_topic_remove
    @classroom = Classroom.find_by_public_id(params[:classroom_id])
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    if topic
      if @classroom.featured_topic_id == topic.id
        next_topic = @classroom.topics.select{|t| t.id != topic.id}.first rescue nil
      end
      topic.destroy
      if next_topic
        @classroom.update_attributes(:featured_topic_id => next_topic.id)
      else
        @classroom.update_attributes(:featured_topic_id => nil)
      end
    end
    render :partial => "classroom_topic_remove"   
  end

  def assign_classroom_referrals
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    @topics_list = (@current_user.favorite_classrooms.collect{|c| c.topics}.flatten + @classroom.reference_topics).uniq.sort{ |a,b| a.title <=> b.title }

     if params[:function] == "Add" 
       added_topic = Topic.find_by_public_id(params[:link_topic_id])
       if @classroom.classroom_referrals.where('topic_id =?',  added_topic.id).empty?
       then flash[:error] = "#{added_topic.title} already a referral for #{@classroom.course_name}."  
       else
        referral = ClassroomReferral.new
        referral.classroom_id = @classroom.id
        referral.topic_id = added_topic.id
        if referral.save then
          flash[:notice] = "#{added_topic.title} was added as a #{@classroom.course_name} referral."  
        else
           flash[:error] = "#{added_topic.title} was not added as a #{@classroom.course_name} referral."  
        end
       end
     end
     if params[:function] == "Remove"        
       removed_topic = Topic.find_by_public_id(params[:link_topic_id])
       referral = @classroom.classroom_referrals.where('topic_id =?', removed_topic.id).first
       unless referral.nil?
         referral.destroy
         flash[:error] = "Notice: #{removed_topic.title} was removed as a Referral for #{@classroom.course_name}."
       end
     end     
  end

 def assign_classroom_resource
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil

 end

  def assign_classroom_resource_view
    @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
    @group_name = params[:group_name]
  end

 def assign_classroom_general
   
    initialize_std_parameters   
    
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @current_topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    
    if params[:function] == "Info" 
      if params[:classroom][:subject_area_id]
        subject_area = SubjectArea.find_by_id(params[:classroom][:subject_area_id])rescue nil
        if subject_area
          @classroom.subject_area_id = subject_area.id
          @classroom.act_subject_id = subject_area.act_subject_id
        end  
      end
      if @classroom.update_attributes(params[:classroom])
        flash[:notice] = 'Classroom was successfully updated.'
      else
        flash[:error] = 'Classroom was not updated.'
      end
    end
    
    if params[:function] == "Resources" 
      add_count = 0
      remove_count = 0 
      params[:res_check] ||= []
      res_list = []
      params[:res_check].each do |r|
      res = Content.find_by_id(r)rescue nil
        unless res.nil?
         res_list<<res
         end
       end
      res_list.uniq.each do |resource|    
         if @classroom.contents.include?(resource) 
           then
           @classroom.contents.delete resource
           remove_count += 1
            else
            @classroom.contents<<resource
            add_count +=1
          end
       end      
       flash[:notice] = "#{add_count} Resources Added,  #{remove_count} Resources Removed" 
      if params[:position]
        positions = params[:position].collect{|p| p}
        params[:classroom_content_id].each_with_index do |cl,i|
          clsrm_resource = ClassroomContent.find_by_id(cl) rescue nil
          if clsrm_resource && positions[i] then
            clsrm_resource.update_attributes(:display_position => positions[i])
          end
        end  
      end
    end
   
    if params[:function] == "Topic" 
      @topic = @classroom.topics.new(params[:topic])
      @topic.user = @current_user 
      @topic.is_open = true
      @topic.should_notify = true
      @topic.act_score_range_id = @classroom.act_subject.nil? ? nil : @classroom.act_subject.act_score_ranges.where('upper_score = ?', 0).first.id
      if @topic.save
         unless @classroom.featured_topic
          @classroom.update_attributes(:featured_topic => @topic)
         end
        flash[:notice] = "Topic successfully created"
       else
        flash[:error] = "Topic Not Created"
      end 
    end

    if params[:function] == "Destroy"
    then
      destroy_count = 0 
      params[:tpc_destroy] ||= []
      tpc_list = []
      params[:tpc_check].each do |t|
        topic = Topic.find_by_id(t) rescue nil
        if topic
          if @classroom.featured_topic_id == topic.id
            next_topic = @classroom.topics.select{|t| t.id != topic.id}.first rescue nil
          end
          topic.destroy
          destroy_count += 1
          if next_topic
             @classroom.update_attributes(:featured_topic_id => next_topic.id)
          else
             @classroom.update_attributes(:featured_topic_id => nil)
          end
        end
      end
      flash[:notice] = "#{destroy_count} #{@classroom.course_name} Topics Permanently Removed" 
    end
    
    
    if params[:function] == "Links"    
      add_count = 0
      remove_count = 0 
      params[:tpc_check] ||= []
      tpc_list = []
      params[:tpc_check].each do |t|
        referral= @classroom,classroom_referrals.where('topic_id =?', t.to_i).first rescue nil
        unless referral
          referral = ClassroomReferral.new
          referral.classroom_id = @classroom.id
          referral.topic_id = t       
          if referral.save then
            add_count +=1
          end       
        end
      end
     flash[:notice] = "#{add_count} Learning Unit Links Added" 
    end    

    if params[:function] == "People"    
    @classroom_auth = params[:auth_level]
    @follower_list = @current_organization.friends_of_org
    authorization_level = AuthorizationLevel.first(:include => :applicable_scopes, :conditions => ["authorization_levels.name = ? AND applicable_scopes.name = ?", @classroom_auth, "Classroom"])
    if @classroom_auth == "leader"
      @remove_list = @classroom.leaders.sort{|a,b| a.last_name.downcase <=> b.last_name.downcase}
       elsif @classroom_auth == "participant"
       @remove_list = @classroom.participants.sort{|a,b| a.last_name.downcase <=> b.last_name.downcase}
         else
         @remove_list = []
      end
     @add_list = (@follower_list - @remove_list).sort{|a,b| a.last_name.downcase <=> b.last_name.downcase}
      add_count = 0
      remove_count = 0 
      params[:user_check] ||= []
      params[:user_check].each do |usr|
        person = User.find(usr) rescue nil
          if @remove_list.include?(person)
            if (person.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(@classroom, @classroom.class.to_s, authorization_level))
               person.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(@classroom, @classroom.class.to_s, authorization_level).destroy
            remove_count += 1
            end
          else
            person.authorizations.create :authorization_level => authorization_level, :scope => @classroom
            person.add_as_favorite_to(@classroom) unless person.has_authorization_level_for?(@classoom, "favorite")
            # Notifier.deliver_classroom_authorization(:user => person, :admin => @current_user, :classroom => @classroom, :current_organization => @current_organization, :authorization_level => authorization_level, :fsn_host => request.host_with_port)
            add_count += 1
        end
      end
     flash[:notice] = "#{add_count} People Added,  #{remove_count} People Removed"
    end    
   
    @avail_resources = (@current_user.favorite_resources + @classroom.contents).uniq.compact
    @avail_resources.sort!{|a,b| a.content_resource_type.name.capitalize <=> b.content_resource_type.name.capitalize}
    @authorization_levels = AuthorizationLevel.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'favorite') AND applicable_scopes.name = ?", "Classroom"])  
   end  
  
  def manage_topic
    
    initialize_std_parameters   
    
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    @colleagues = @current_user.colleagues.sort{|a,b| a.last_name.downcase <=> b.last_name.downcase}rescue nil


    if params[:function] == "Resource" 
      
      if params[:position]
        positions = params[:position].collect{|p| p}

        params[:topic_content_id].each_with_index do |tr,i|
        tpc_resource = TopicContent.find_by_id(tr) rescue nil
          if tpc_resource && positions[i] then
            tpc_resource.update_attributes(:display_position => positions[i])
          end
       end  
      end
      
      add_count = 0
      remove_count = 0
      featured_removed = false
      params[:res_check] ||= []
      res_list = []
      params[:res_check].each do |r|
      res = Content.find_by_id(r)rescue nil
      unless res.nil?
        res_list<<res
        end
      end
      res_list.uniq.each do |resource|    
        if @topic.contents.include?(resource) 
          then
          @topic.contents.delete resource
          remove_count += 1
           if @topic.featured_content == resource.id
              @topic.featured_content = nil
              if @topic.save then    
                featured_removed = true
              end
           end
         else
         @topic.contents<<resource
         add_count +=1
       end
       @topic.sequence_resources
       end
      if featured_removed then
          flash[:error] = "#{add_count} Resources Added,  #{remove_count} Resources Removed FEATURED RESOURCE REMOVED!" 
       else 
          flash[:notice] = "#{add_count} Resources Added,  #{remove_count} Resources Removed" 
       end
     else
   end
      
    if params[:function] == "Assess"  && @topic   
      if params[:commit] == "UPDATE INFORMATION"
       then
        params[:add_check] ||= []
        std_list = []
        params[:add_check].each do |s|
        std = ActStandard.find_by_id(s)rescue nil
          unless std.nil?
            std_list<<std
            end
          end        
        std_list.uniq.each do |standard|    
          unless @topic.act_standards.include?(standard) 
           @topic.act_standards << standard
            end
        end
        params[:del_check] ||= []
        std_list = []
        params[:del_check].each do |s|
        std = ActStandard.find_by_id(s)rescue nil
          unless std.nil?
           @topic.act_standards.delete std rescue nil
            end
          end   
        if @topic.update_attributes(params[:topic])
          unless params[:t_range][:act_score_range_id].empty?
            existing_range = @topic.act_score_ranges.for_standard(@current_standard).first rescue nil
            new_range = ActScoreRange.find_by_id(params[:t_range][:act_score_range_id])
            if existing_range
              @topic.act_score_ranges.delete existing_range
            end
            unless @topic.act_score_ranges.include?(new_range) 
              @topic.act_score_ranges << new_range
            end            
          end
          flash[:notice] = "#{@topic.title} Assessment Info Updated"
        else
          flash[:error] = "#{@topic.title} Assessment Info Not Successfully Updated"
       end
     end
   end
   
    if params[:function] == "Info"  && @topic   
      if params[:commit] == "UPDATE INFORMATION"
       if @topic.update_attributes(params[:topic])
            flash[:notice] = "#{@topic.title} Updated"
         else
            flash[:error] = "#{@topic.title} Not Successfully Updated"
       end
      end
      
      if params[:commit] == "DESTROY TOPIC" && @topic
        @topic.destroy
        redirect_to :action => :static_classroom, :organization_id => @current_organization, :id => @classroom
      end 
    end  
 

      if @topic 
      then resource_ids = @topic.topic_contents.sort{|a,b|a.display_position <=> b.display_position}
      else resource_ids = []
    end
    @current_resources = []
    resource_ids.each do |r|
    @current_resources<<r.content
    end

#
# Get available resources from colleagues & tagged classrooms
#
    @avail_resources = []
    @col_resources = []
    @current_user.colleagues.each do |col|
    @col_resources += col.contents.active
    end
#    @classroom_resources = []
#    @current_user.favorite_classrooms.each do |clsrm|
#     clsrm.topics.each do |tpc|
#       @classroom_resources += tpc.contents
#       end
#    end
  @fav_topics = @current_user.favorite_classrooms.collect{|c| c.topics}
  @avail_resources =  (@current_user.favorite_resources + @col_resources).uniq.compact
  @avail_resources.sort!{|a,b| a.content_resource_type.name <=> b.content_resource_type.name}
  end

  def assign_topic_resource_view
    @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    if params[:fav_topic]
      @tagged_topic = Topic.find_by_public_id(params[:fav_topic])rescue nil
    end
  render :partial => "manage_topic_resources_others"
  end
  

  def edit_topic
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
  end
  
  def topic_assess
    
    initialize_std_parameters   
        
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    first_range = @topic.act_score_ranges.first rescue nil
    @topic_subject = first_range ? first_range.act_subject : @classroom.act_subject
    @master = first_range ? first_range.act_master : ActMaster.default_std
   render :partial => "ifa_topic_update"  
  end

  def topic_assess_new_master_or_subject
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @master = ActMaster.find(params[:master_id]) rescue nil
   @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
   @topic_subject = ActSubject.find(params[:subject_id]) rescue nil
   render :partial => "ifa_topic_update"  
  end 

  def topic_assess_ifa_tags
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
   @master = ActMaster.find(params[:master_id]) rescue nil
   @topic_subject = ActSubject.find(params[:subject_id]) rescue nil
   unless @master
     @master = ActMaster.default_std
   end
   score_range = ActScoreRange.find_by_public_id(params[:range_id]) rescue nil
   strand = ActStandard.find_by_public_id(params[:strand_id]) rescue nil   
   if score_range
     if !@topic.act_score_ranges.include?(score_range)
       add_range = true
     end
     @topic.act_score_ranges.for_standard(@master).each do |existing_range|
        @topic.act_score_ranges.delete existing_range
      end
      if add_range 
        @topic.act_score_ranges << score_range
      end
   end
   if strand
     if @topic.act_standards.include?(strand)
       @topic.act_standards.delete strand
     else
       @topic.act_standards << strand
     end 
   end   
   render :partial => "ifa_topic_update"  
  end 
 
  def list_topic_resources
    @topic = Topic.find_by_public_id(params[:topic_id])
    @classroom = Classroom.find_by_public_id(params[:classroom_id])
    @clsrm = Classroom.find_by_public_id(params[:id])
  end 
  
  def list_classroom_referrals
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
    render :partial => "manage_classroom_referrals"
  end 

  def list_classroom_topics
    @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
  end 
 
  def assign_classroom_referral_links
    @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
    @clsrm = Classroom.find_by_public_id(params[:id])rescue nil
    @avail_links = @clsrm.topics - @classroom.reference_topics
  end 

 
   def set_featured_resource
    @topic = Topic.find_by_public_id(params[:id])rescue nil
    @topic.featured_content = Content.find_by_public_id(params[:content_id]).id
    if @topic.save then
      flash[:notice] = "Updated topic featured content"
    else
      flash[:error] = "Error: Topic featured content could not be saved" 
    end
    render :partial => "notice"    
  end
 
 def manage_topic_set_featured_resource
     @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
     @current_organization = Organization.find_by_public_id(params[:organization_id])
     resource = Content.find_by_public_id(params[:resource_id]) rescue nil
     if resource
       if @topic.featured_content == resource.id
         @topic.update_attributes(:featured_content => nil)
       else
         @topic.update_attributes(:featured_content => resource.id)
       end
     end
     render :partial => "manage_topic_resources"
 end
 

 def manage_topic_add_remove_resource
     @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
     @current_organization = Organization.find_by_public_id(params[:organization_id])
     resource = Content.find_by_public_id(params[:resource_id]) rescue nil
     if resource
        if @topic.contents.include?(resource)
          @topic.contents.delete resource
          if @topic.featured_content == resource.id
            @topic.update_attributes(:featured_content => nil)
          end
        else
          @topic.contents<<resource
        end
        @topic.sequence_resources
     end
     if params[:type_id]
      @resource_tag = ContentResourceType.find_by_id(params[:type_id]).name 
      @resource_pool = @current_user.favorite_resources.compact.select{|r| (r.content_status.name == "Available" || r.content_status.name =="Restricted") && (r.content_resource_type_id == params[:type_id].to_i) } rescue []
      @resource_pool.sort!{|a,b| b.created_at <=> a.created_at} 
     end
     if params[:fav_topic_id]
       @tagged_topic = Topic.find_by_id(params[:fav_topic_id])rescue nil
     end
     @topic = Topic.find_by_public_id(params[:topic_id])rescue nil 
     render :partial => "manage_topic_resources"
 end  


 def manage_topic_resource_sequence
     @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
     @current_organization = Organization.find_by_public_id(params[:organization_id])
     resource = Content.find_by_public_id(params[:resource_id]) rescue nil
     if resource
      resources = @topic.topic_contents.sort_by{|tc| tc.position} rescue []
      resources.each_with_index do|tc,idx|
      if tc.content_id == resource.id
        if params[:direction]=="up" && idx>0
          base_position = tc.position
          tc.update_attributes(:position => resources[idx-1].position)
          resources[idx-1].update_attributes(:position => base_position)
        end
        if params[:direction]=="down" && (idx+1)<resources.size
          base_position = tc.position
          tc.update_attributes(:position => resources[idx+1].position)
          resources[idx+1].update_attributes(:position => base_position)
        end 
        if params[:direction]=="top"
          tc.update_attributes(:position => 1)
          jdx = 0
          until jdx == idx
           resources[jdx].update_attributes(:position => resources[jdx].position + 1)
           jdx += 1
          end
        end  
      end
    end
    @topic.sequence_resources
   end
   render :partial => "manage_topic_resources" 
 end
 
 def manage_classroom_resource_sequence
     @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
     @current_organization = Organization.find_by_public_id(params[:organization_id])
     resource = Content.find_by_public_id(params[:resource_id]) rescue nil
     if resource
      resources = @classroom.classroom_contents.sort_by{|cc| cc.position} rescue []
      resources.each_with_index do|cc,idx|
      if cc.content_id == resource.id
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
    @classroom.sequence_resources
   end
   render :partial => "manage_classroom_resources" 
 end 
  
 def manage_classroom_remove_resource
     @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
     @current_organization = Organization.find_by_public_id(params[:organization_id])
     resource = Content.find_by_public_id(params[:resource_id]) rescue nil
     if resource
       @classroom.contents.delete resource
       @classroom.sequence_resources
     end
     render :partial => "manage_classroom_resources"
 end 

  def manage_classroom_add_remove_resource
     @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
     @current_organization = Organization.find_by_public_id(params[:organization_id])
     resource = Content.find_by_public_id(params[:resource_id]) rescue nil
     if resource
       if @classroom.contents.include?(resource)
        @classroom.contents.delete resource
        @classroom.sequence_resources
      else
        @classroom.contents<<resource
      end
     end
     if params[:type_id]
      @resource_tag = ContentResourceType.find_by_id(params[:type_id]).name 
      @resource_pool = @current_user.favorite_resources.compact.select{|r| (r.content_status.name == "Available" || r.content_status.name =="Restricted") && (r.content_resource_type_id == params[:type_id].to_i) && [2,5,7,8].include?(r.content_object_type.content_object_type_group_id)} rescue []
      @resource_pool.sort!{|a,b| b.created_at <=> a.created_at} 
     end
     @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
     render :partial => "manage_classroom_resources"  
  end


 def manage_classroom_add_remove_referral
     @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
     @current_organization = Organization.find_by_public_id(params[:organization_id])
     referral = ClassroomReferral.find_by_id(params[:referral_id]) rescue nil
     if referral
         @classroom.classroom_referrals.delete referral
     else
      referral_topic = Topic.find_by_public_id(params[:ref_topic_id]) rescue nil
      if referral_topic
         referral = @classroom.classroom_referrals.where('topic_id =?', referral_topic.id).first rescue nil
        if referral
          @classroom.classroom_referrals.delete referral
        else
          referral = ClassroomReferral.new
          referral.classroom_id = @classroom.id
          referral.topic_id = referral_topic.id    
          referral.save
        end     
      end     
     end
     if params[:tagged_classroom_id]
       @tagged_classroom = Classroom.find_by_id(params[:tagged_classroom_id]) rescue nil
     end
     @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
     render :partial => "manage_classroom_referrals"
 end
 
  def create_or_edit_topic
    @classroom = Classroom.find_by_public_id(params[:classroom_id])
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    if params[:commit] == "UPDATE TOPIC"
      then
      @topic = Topic.find_by_public_id(params[:topic_id]) 
      if params[:close] =="yes"
        @topic.is_open = false
      end
      if params[:close] =="no"
        @topic.is_open = true
      end 
      if params[:notfy] =="yes"
        @topic.should_notify = true
      end
      if params[:notfy] =="no"
        @topic.should_notify = false
      end
      
       if @topic.update_attributes(params[:topic])
         then
            if params[:featured] == "yes"
              then
                  @classroom.update_attributes(:featured_topic => @topic) unless @classroom.featured_topic == @topic
            end
            flash[:notice] = "#{@topic.title} Updated"
            else
            flash[:error] = "#{@topic.title} Not Successfully Updated"
        end
        redirect_to :action => :manage_topic
      end
   if params[:commit] != ("DELETE TOPIC" || "UPDATE TOPIC")
        @topic = Topic.find_by_public_id(params[:topic_id])
        redirect_to :action => :manage_topic
   end
 end
  
 def create_new_topic
    @classroom = Classroom.find_by_public_id(params[:classroom_id])
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    if params[:commit] == "Create New Topic"
     then
      @topic = @classroom.topics.new(params[:topic])
      @topic.user = @current_user 
      if params[:close] =="yes"
        @topic.is_open = false
      end
      if params[:notfy] =="no"
        @topic.should_notify = false
      else
        @topic.should_notify = true  
      end

       if @topic.save
         unless @classroom.featured_topic
          @classroom.update_attributes(:featured_topic => @topic.id)
         end
        flash[:notice] = "Topic successfully created"
        redirect_to :action => :static_classroom, :organization_id => @current_organization, :topic_id => @topic, :id => @classroom
      else
        flash[:error] = "Topic Not Created"
     end
    end
 end
  
 def submit_homework
    @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
    @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    unless params[:topic_id].nil? 
      @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    end
    @teacher_list = @classroom.teachers_for_student(@current_user).sort{|a,b| a.last_name.downcase <=> b.last_name.downcase}
    @submitted = false
    if params[:commit] == "Submit Homework"
     then
      @homework = @classroom.homeworks.new(params[:homework])
      @homework.user = @current_user
      @homework.classroom = @classroom
      @homework.topic_title = @topic.title
      @homework.homework = params[:homework][:homework]
      @homework.content_object_type = ContentObjectType.find_by_content_object_type(@homework.homework_file_name.match(/\.[\w]+/).to_s.match(/\w+/).to_s) unless @homework.homework_file_name.blank?
      if @homework.save
        teacher = User.find_by_id(@homework.teacher_id)
        flash[:notice] = "#{@current_user.first_name}, #{@homework.homework_file_name} Has Been SUCCESSFULLY SUBMITTED To #{teacher.full_name}."
        @submitted = true
      else
          flash[:error] = @homework.errors.full_messages.to_sentence
     end
    end
 end  
 
  def submit_homework_review
    @classroom = Classroom.find_by_public_id(params[:classroom_id])rescue nil
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    unless params[:topic_id].nil? 
      @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    end
   @teacher_homeworks = @classroom.homeworks.active.select{|h|h.teacher_id == @current_user.id}
  end
  
  
  
  def index
    if @current_topic
      # @discussions = @current_topic.discussions.active.paginate(:page => params[:page], :conditions => ["parent_id IS NULL"], :order => "created_at DESC")
      @discussions = @current_topic.discussions.active.parent_id_blank(:order_by =>  "created_at DESC")
    else
      @discussions = []
      # @discussions = [].paginate
    end
    redirect_to :action => :static_organization
    # respond_to do |format|
    #   format.html
    #   format.js { render :template => 'site/discussions/_discussions', :layout => false}
    # end
  end
  
  def more_topic
    @discussions = @current_topic.discussions.active.paginate(:page => params[:page], :conditions => ["parent_id IS NULL"], :order => "created_at DESC")
    respond_to do |format|
      format.html
      format.js { render :template => 'site/discussions/_discussions', :layout => false}
    end
  end
  
  def update_index
    @discussions = @current_topic.discussions.paginate(:page => params[:page], :conditions => ["parent_id IS NULL"], :order => "created_at DESC")
    render :template => "site/discussions/_discussions", :layout => false
  end
  
  def featured_content
    render :layout => false
  end
  
  def related_content
    if params[:folder_id]
      @folder = Folder.find_by_public_id params[:folder_id] rescue nil
    else
      @folder = nil
    end
    render :layout => false
  end
  
  def related_content_list
    @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    if params[:folder_id]
      @folder = Folder.find_by_public_id params[:folder_id] rescue nil
    else
      @folder = nil
    end
    render :partial => "related_content_list", :locals => {:topic => @topic, :folder => @folder, :featured_resource => @content}
  end
  
  def show_content
    @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    if params[:folder_id]
      @folder = Folder.find_by_public_id params[:folder_id] rescue nil
    else
      @folder = nil
    end
    @content = Content.active.find_by_public_id params[:id] rescue nil
    render :layout => false
  end

  def show_share_content
    @content = Content.active.find_by_public_id params[:id] rescue nil
  end
  
  def show_result_content
    @content = Content.active.find_by_public_id params[:id] rescue nil
    render :layout => false
  end
  
  def search
    search_user = @current_user ? @current_user : nil 
    @filter_type = "None" 
    @filter = params[:filter] || "-- No Filter --"

    @search_type = params[:search_type] || "Resource"
    load_search_fields
    @order_by = params[:order_by]

    case @order_by
    when "people_name"
      order_by = "last_name, first_name"
    # when "religious_affiliation_name"
    #   order_by = "religious_affiliations.name"
    when "organization_provider", "organization_name"
      order_by = "organizations.name"
    when "subject_area"
      order_by = "description"
      #
      # ALK addition of Resource_Type ordering for Search Results
      #
    when "resource_type"
      order_by = "resource_type"
      #
    when "type"
      order_by = "content_object_type_groups.name"
    when "title", "topic_category"
      order_by = "title"
    end
    if @keywords
      @keywords.delete!("?*(+[|\\")
    end
  
#   People Search  
    if @search_type == "People"
      order_by ||= "last_name, first_name"
      @filter_type = "People"
      if @keywords.blank?
         items_found = User.where('users.id != ? and verified_at IS NOT NULL"', 1).order(order_by)
      else
        if @search_field == "Role"
          items_found = User.with_roles @keywords, :order => order_by
        elsif @search_field == "Person's Name"
          items_found = User.with_names @keywords, :order => order_by
        elsif @search_field == "Organization"

          items_found = User.with_organizations @keywords, :order => order_by 
#
         else
 #          items_found = User.with_talent @keywords, :order => order_by
           items_found = User.with_names @keywords, :order => order_by
        end
     end
     
     @filter_descript = []
     unless @filter.nil?
        
        if @filter != "-- No Filter --"
          @filter_descript = AuthorizationLevel.find_by_id(@filter).description
          people = items_found
          items_found = []
          people.each do |u|
            auth = u.authorizations.where('authorization_level_id = ?', @filter).first rescue nil
            if auth
              items_found << u
            end
          end
        end
    end
    @org_auth_levels = AuthorizationLevel.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'friend') AND applicable_scopes.name = ?", "Organization"])
    @clsrm_auth_levels = AuthorizationLevel.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'friend','favorite') AND applicable_scopes.name = ?", "Classroom"])
    
#   Org Search    
    elsif @search_type == "Organizations"
      order_by ||= "organizations.name"
      @filter_type = "Organization"
      if @keywords.blank?
        items_found = Organization.active(:order => order_by)
      else
          items_found = Organization.active.with_names @keywords, :order => order_by
      end
      unless @filter.nil?
        if @filter != "-- No Filter --" 
          items_found = items_found.select{|o| (o.organization_type.name == @filter)}
        end
      end


#   Classroom Search      
      #
      # ALK: Search Type of "Causes" equates to "Classrooms"
      #
    elsif @search_type == "Offerings"
      order_by ||= "course_name"
      @filter_type = "Classroom"
      if @keywords.blank?
        items_found = Classroom.active.all(:include => :organization, :order => order_by)
      else
        if @search_field == "Subject Area"
          items_found = Classroom.active.with_subject_areas @keywords, :order => order_by
        elsif @search_field == "Organization"
          items_found = Classroom.active.with_organizations @keywords, :order => order_by
        else
          items_found = Classroom.active.with_course_names @keywords, :order => order_by
        end
      end
      unless @filter.nil?
        if @filter != "-- No Filter --" 
          items_found = items_found.select{|cl| (cl.organization.name == @filter)}
        end
      end
 #   Resource Search     
    else
      order_by ||= "title"
      @filter_type = "Resource"
      if @keywords.blank?
          items_found = Content.available_to_user(search_user)
      else
        if @search_field == "Organization"
          items_found = Content.available_to_user_organization(search_user, @keywords, @current_organization, order_by)
        elsif @search_field == "Subject Area"
          items_found = Content.available_to_user_subject(search_user, @keywords, @current_organization, order_by)
        else
          items_found = Content.available_to_user_with_keywords(search_user, @keywords, @current_organization, order_by)
        end
      end
      #
      #  ALK Filter out Unavailable & expired Content And show Restricted contnet for Content managers
 #     if (@current_user.nil?) 
 #       items_found = items_found.select{|c| (c.content_status.name == "Available") && (c.publish_end_date > Time.now)}
 #      elsif @current_user.has_authorization_level?("content_manager", :ignore_superuser => true) || @current_user.has_authorization_level?("administrator", :ignore_superuser => true)
 #        items_found = items_found.select{|c| (c.content_status.name == "Available" || "Restricted") && (c.publish_end_date > Time.now)}
 #         else 
 #         items_found = items_found.select{|c| (c.content_status.name == "Available") && (c.publish_end_date > Time.now)}
 #     end
      unless @filter.nil?
        if @filter != "-- No Filter --" 
          items_found = items_found.select{|c| (c.content_resource_type.name == @filter)}
        end
      end
    end
    @items_size = items_found.size
    @items_found = items_found.paginate(:per_page => 10, :page => params[:page])   
    render :partial => "search_results" if params[:page]
  end
 
  def search_form
    @search_type = params[:search_type]
    load_search_fields
    render :partial => "search_form"
  end
  
  def keywords_autocomplete
    load_search_fields
    text = ""
    if @search_field == "Person's Name"
  #    text = User.find(:all, :conditions => ["(last_name LIKE ? OR last_name LIKE ?)", "#{params[:q]}%","% #{params[:q]}%"], :order => "last_name").collect{|o| o.last_name}.join("\n")
      text = User.where('last_name LIKE ? OR last_name LIKE ?', "#{params[:q]}%","% #{params[:q]}%").order('last_name').collect{|o| o.last_name}.join("\n")
    elsif @search_field == "Name"
  #    text = Organization.find(:all, :conditions => ["(name LIKE ? OR name LIKE ?)", "#{params[:q]}%","% #{params[:q]}%"], :order => "name").collect{|o| o.name}.join("\n")
      text = Organization.where('name LIKE ? OR name LIKE ?', "#{params[:q]}%","% #{params[:q]}%").order('name').collect{|o| o.name}.join("\n")
    elsif @search_field == "Auth"
  #    text = User.find(:all, :conditions => ["(last_name LIKE ? OR last_name LIKE ?)", "#{params[:q]}%","% #{params[:q]}%"], :order => "last_name").collect{|o| o.last_name}.join("\n")
      text = User.where('(last_name LIKE ? OR last_name LIKE ?)', "#{params[:q]}%","% #{params[:q]}%").order('last_name').collect{|o| o.last_name}.join("\n")
    elsif @search_field == "Subject Area"
      text = SubjectArea.where('(name LIKE ? OR name LIKE ?)', "#{params[:q]}%","% #{params[:q]}%").order('name').collect{|o| o.name}.join("\n")
  #    text = SubjectArea.find(:all, :conditions => ["(name LIKE ? OR name LIKE ?)", "#{params[:q]}%","% #{params[:q]}%"], :order => "name").collect{|o| o.name}.join("\n")
    end
    
    render :text => text
  end

  def add_star_rating_to_content
    # if @current_topic
    # @content = @current_topic.contents.find_by_public_id params[:id]
    # end
    @content = Content.active.find_by_public_id params[:id]
    @content.add_star_rating(params[:rating])
    render :partial => "/shared/vote",
      :locals => {:content => @content, :checked => false, :disabled => true, :rating => params[:rating]},
      :layout => false
  end
  
  def content_index
    #  @contents = @current_organization.contents.paginate :per_page => 10, :page => params[:page], :conditions => "content_upload_source_id = 2 AND pending = false"

    @contents = []
    # @contents = @current_organization.contents.find(:all , :conditions => ["content_object_types.content_object_type_group_id=4 AND content_upload_source_id = 2 AND pending = false"] , :include => :content_object_type)
    @contents = @current_organization.contents.find(:all , :conditions => ["content_object_types.content_object_type_group_id=4"] , :include => :content_object_type)
    @content_count = @contents.size
    @contents = @contents.paginate :per_page => 10, :page => params[:page]
    
    # @content_images = @current_organization.contents.find(:all , :conditions => ["content_object_types.content_object_type_group_id=2 AND content_upload_source_id = 2 AND pending = false"] , :include => :content_object_type)
    @content_images = @current_organization.contents.find(:all , :conditions => ["content_object_types.content_object_type_group_id=2"] , :include => :content_object_type)
    @image_count = @content_images.size
    @content_images = @content_images.paginate :per_page => 10, :page => params[:page]
   
    # @content_videos = @current_organization.contents.find(:all , :conditions => ["content_object_types.content_object_type_group_id=1 AND content_upload_source_id = 2 AND pending = false"] , :include => :content_object_type)
    @content_videos = @current_organization.contents.find(:all , :conditions => ["content_object_types.content_object_type_group_id=1"] , :include => :content_object_type)
    @video_count = @content_videos.size
    @content_videos = @content_videos.paginate :per_page => 10, :page => params[:page]
    # @contents = @current_organization.contents.paginate :per_page => 10, :page => params[:page], :conditions => "pending = false"
  end
  
  def content_images_page
    @content_images = @current_organization.contents.find(:all , :conditions => ["content_object_types.content_object_type_group_id=2 AND content_upload_source_id = 2 AND pending = false"]  , :include => :content_object_type).paginate :per_page => 10, :page => params[:page]
    render :layout => false
  end
  
  def content_videos_page
    @content_videos = @current_organization.contents.find(:all , :conditions => ["content_object_types.content_object_type_group_id=1 AND content_upload_source_id = 2 AND pending = false"] , :include => :content_object_type).paginate :per_page => 10, :page => params[:page]
    render :layout => false
  end
  
  def content_other_page
    @contents = @current_organization.contents.find(:all , :conditions => ["content_object_types.content_object_type_group_id=4 AND content_upload_source_id = 2 AND pending = false"] , :include => :content_object_type)
    @content_count = @contents.size
    @contents =@contents.paginate :per_page => 10, :page => params[:page]
    render :layout => false
  end
  
  def content_show
    if request.xhr?
      @content = Content.find_by_public_id(params[:id])
      # respond_to do |wants|
      #   wants.html { render :template => "/admin/content/show" }
      # end
    end
  end
  
  def content_search
    if request.xhr?
      @keywords = params[:keywords]
      @contents = (@current_organization.contents.with_keywords @keywords, :organization => @current_organization).paginate :per_page => 10, :page => params[:page]
      render :template => "/site/#{params[:render_html]}"
    end
  end

  
  def select_subject_areas
    subjects = SubjectArea.auto_complete_on params[:q]
    render :text => subjects.empty? ? "" : subjects.collect{|subject| "#{subject.name}\n"}
  end
  
  def select_resource_types
    rtypes = ContentResourceType.auto_complete_on params[:q]
    render :text => rtypes.empty? ? "" : rtypes.collect{|rtype| "#{rtype.name}\n"}
  end

  def set_classroom_ifa_days_repeat
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    if @classroom.ifa_classroom_option && params[:dtr]
      repeat_days = params[:dtr].to_i >= 0 ? params[:dtr].to_i : 0
      @classroom.ifa_classroom_option.update_attributes(:days_til_repeat => repeat_days)
    end
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil    
    render :partial => "manage_classroom_ifa", :locals=>{:classroom => @classroom} 
  end  
  
  def toggle_classroom_ifa_enable
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    if @classroom.ifa_classroom_option
      @classroom.ifa_disable
    else
      @classroom.ifa_enable
    end
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil    
    render :partial => "manage_classroom_ifa", :locals=>{:classroom => @classroom} 
  end
  
  def toggle_classroom_ifa_notify
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    if @classroom.ifa_classroom_option
      @classroom.ifa_classroom_option.update_attributes(:is_ifa_notify =>!@classroom.ifa_classroom_option.is_ifa_notify)
    end
    render :partial => "manage_classroom_ifa", :locals=>{:classroom => @classroom} 
  end
  
  def toggle_classroom_ifa_auto_finalize
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    if @classroom.ifa_classroom_option
      @classroom.ifa_classroom_option.update_attributes(:is_ifa_auto_finalize =>!@classroom.ifa_classroom_option.is_ifa_auto_finalize)
    end
    render :partial => "manage_classroom_ifa", :locals=>{:classroom => @classroom}
  end

  def toggle_classroom_homework_option
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @classroom.update_attributes(:homework_option =>!@classroom.homework_option)
    render :partial => "manage_classroom_options"
  end

############
# In Production Environment An Invalid Method error was generated. 
# With AJAX Call using "function()"
# Needed 2 steps to 1) delete Homework and 2) properly refresh html template.

   def purge_classroom_homework_part1
    homework = Homework.find_by_id(params[:homework_id]) rescue nil
    if homework.update_attributes(:is_deleted => true)
    end

    render :text => "successful"
 #    render :partial => "view_submitted_homeworks"
#    redirect_to :action => :submit_homework_review, :organization_id => @current_organization, :classroom_id => @classroom, :topic_id => @topic
    end
   def purge_classroom_homework_part2
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil

#    render :text => "successful"
    render :partial => "view_submitted_homeworks"
#    redirect_to :action => :submit_homework_review, :organization_id => @current_organization, :classroom_id => @classroom, :topic_id => @topic
    end

   def purge_classroom_homework
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    homework = Homework.find_by_id(params[:homework_id]) rescue nil
    if homework.update_attributes(:is_deleted => true)
    end
#    render :text => "successful"
    render :partial => "view_submitted_homeworks"
#    redirect_to :action => :submit_homework_review, :organization_id => @current_organization, :classroom_id => @classroom, :topic_id => @topic
    end

############

   def purge_all_classroom_homeworks_warning
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    @teacher_warning = true
    render :partial => "manage_classroom_options"
    end 

   def purge_all_classroom_homeworks
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    @teacher_homeworks = @classroom.homeworks.select{|h|h.teacher_id == @current_user.id}
    @teacher_homeworks.each do |homework|
      homework.destroy
    end
    @teacher_warning = false
    render :partial => "manage_classroom_options"
    end 
  
  def set_featured_topic_option
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    @classroom.update_attributes(:featured_topic => @topic) 
    render :partial => "manage_topic_options"
  end
 
  def toggle_topic_discussion
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    @topic.update_attributes(:is_open => !@topic.is_open) 
    render :partial => "manage_topic_options"
  end
 
  def toggle_topic_notification
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    @topic.update_attributes(:should_notify => !@topic.should_notify) 
    render :partial => "manage_topic_options"
  end
 
  def update_topic_homework
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    if @topic.update_attributes(:assignments => params[:homework])
      @homework_updated = true
    end
    render :partial => "update_topic_homework"
  end
             
  def teacher_clear_topic_discussion
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    @topic.discussions.each do |disc|
      disc.suspend!(:user => @current_user)
      end
    render :partial => "manage_topic_options"
  end

  def summarize_org_app

    @app = CoopApp.find_by_public_id(params[:app_id])
    
  end

  def summarize_org_subject_offerings
    @subject = params[:subject_area_id] ? SubjectArea.find_by_public_id(params[:subject_area_id]): nil
    @folder = params[:folder_id] ? Folder.find_by_public_id(params[:folder_id]): nil      
    @display = params[:display]
  end

  def summarize_org_resources
    @subject = SubjectArea.find_by_public_id(params[:subject_area_id])    
  end


  protected
 
  def initialize_site_parameters
    if params[:organization_id]
      @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    end
    if params[:user_id]
      @current_user = User.find_by_public_id(params[:user_id]) rescue nil
    end
     if params[:app_id]
        @app = CoopApp.find_by_id(params[:app_id]) rescue nil
      end
  end

  def initialize_classroom_parameters
    if params[:classroom_id]
      @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    end
    if params[:topic_id]
      @topic = Topic.find_by_public_id(params[:topic_id]) rescue nil
    end
    if params[:student_id]
      @student = User.find_by_public_id(params[:student_id]) rescue nil
      unless @student
        @student = User.find_by_id(params[:student_id]) rescue nil
      end
    end

    if params[:period_id]
      @period = ClassroomPeriod.find_by_public_id(params[:period_id]) rescue nil
      unless @period
        @period = ClassroomPeriod.find_by_id(params[:period_id]) rescue nil
      end
    end

  end
  
  def load_search_fields
    if params[:commit]
      @keywords = params[:prev_keywords]
    else
      @keywords = params[:keywords]
      @filter = "-- No Filter --"
    end
    if @search_type == "People"
      @search_fields = ["Anything", "Person's Name", "Organization"]
    elsif @search_type == "Organizations"
 
      @search_fields = ["Name"]
      #
      # ALK change Search Type from "Causes" to "Classrooms"
      #
    elsif @search_type == "Classrooms"
      @search_fields = ["Learning Unit", "Subject Area", "Organization"]
    else
      @search_fields = ["Title/Description", "Subject Area", "Organization"]
      # ALK put back organization as a field
      #@search_fields = ["title or description"]
    end
    @search_field = params[:search_field] || @search_fields.first
  end
  
  def initialize_std_parameters 
    @standards = ActStandard.all.collect{|s|[s.standard]}.uniq.sort
    if @current_user
      @std_view = @current_user.std_view.to_s
      @current_standard = @current_user.act_master
    else
      @std_view = "act"
      @current_standard = ActMaster.all.first
    end
    
      
  end
  
end
