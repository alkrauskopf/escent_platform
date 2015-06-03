class Site::ContentsController < Site::ApplicationController   

  helper :all # include all helpers, all the time      
  layout "site", :except =>[:user_resources, :edit_assess, :show_group_content]

  before_filter :clear_notification

  
  def clear_notification
#    flash[:notice] = nil
 #   flash[:error] = nil
  end
 

  def index
    
    initialize_std_parameters
    content_groupings   
    @current_group = params[:current_group] ? params[:current_group].titleize : "Folder"
   if params[:organization_id]
    @current_organization = Organization.find_by_public_id(params[:organization_id]) 
   end
   @resources = @current_user.administrator_of?(@current_organization) ? @current_organization.contents : Content.find(:all, :conditions => ["user_id = ? AND organization_id = ?", @current_user.id, @current_organization.id])
   @resources.sort!{|a,b| a.content_resource_type.name <=> b.content_resource_type.name}
  end  

  def show_group_content
    org = Organization.find_by_public_id(params[:org_id]) rescue nil
    if org && params[:entity_class] == "Folder"
      @current_group = params[:entity_class]
      entity = Folder.find_by_id(params[:entity_id].to_i) rescue nil
      if entity
        @resource_list = @current_user.content_admin?(org) ? entity.lu_resources.for_org(org) : entity.lu_resources.for_user(@current_user).for_org(org)      
      else
        @resource_list = []
      end
    elsif org && params[:entity_class] == "ContentResourceType"
      @current_group = "Type"
      entity = ContentResourceType.find_by_id(params[:entity_id].to_i) rescue nil
      if entity
        @resource_list = @current_user.content_admin?(org) ? org.contents.for_type(entity) : org.contents.for_user(@current_user).for_type(entity)     
      else
        @resource_list = []
      end    
    else
      @resource_list = []
      @content_group = ""    
    end
  end


  def select_content_group
    content_groupings  
    @current_group = params[:current_group].titleize
    render :partial => "site/contents/list_content_groups", :locals => {:org=>@current_organization, :content_groups=>@content_groups, :current_group=>@current_group}

  end
 
  def submit_resource
    
    initialize_std_parameters
    
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    if params[:function]=="New"
      @content = Content.new
    else
      if params[:function] == "Submit"
        @content = @current_organization.contents.new(params[:content])
        @content.user = @current_user
        @content.target_score_range = "-na-"
        unless params[:content][:content_resource_type_id].empty?
          resource_type = ContentResourceType.find_by_id(params[:content][:content_resource_type_id])
          @content.resource_type = resource_type.name          
          @content.content_resource_type = resource_type
        end
        unless params[:content][:subject_area_id].empty?
          subject_area = SubjectArea.find_by_id(params[:content][:subject_area_id])
          @content.subject_area_old = subject_area.name
          @content.subject_area_id = subject_area.id          
          unless params[:content][:act_subject_id].empty?
            @content.act_subject_id = params[:content][:act_subject_id]
          else
            @content.act_subject_id = subject_area.act_subject_id
          end
          if @content.act_subject_id == 1
            unless params[:math][:act_score_range_id].empty?
               target_score_id = params[:math][:act_score_range_id]
            end
          end
          if @content.act_subject_id == 2
            unless params[:eng][:act_score_range_id].empty?
               target_score_id = params[:eng][:act_score_range_id]
            end
          end
          if @content.act_subject_id == 3
            unless params[:read][:act_score_range_id].empty?
               target_score_id = params[:read][:act_score_range_id]
            end
          end
          if @content.act_subject_id == 4
            unless params[:sci][:act_score_range_id].empty?
               target_score_id = params[:sci][:act_score_range_id]
            end
          end
          if @content.act_subject_id == 5
            unless params[:wrt][:act_score_range_id].empty?
               target_score_id = params[:wrt][:act_score_range_id]
            end
          end
          new_range = ActScoreRange.find_by_id(target_score_id)rescue nil
          if new_range
            existing_range = @content.act_score_ranges.for_standard(@current_standard).first rescue nil
              if existing_range
                @content.act_score_ranges.delete existing_range
              end
              unless @content.act_score_ranges.include?(new_range) 
                @content.act_score_ranges << new_range
              end            
            end
          end
        params[:std_check] ||= []
        std_list = []
        params[:std_check].each do |s|
        std = ActStandard.find_by_id(s)rescue nil
          unless std.nil?
            std_list<<std
            end
          end        
        std_list.uniq.each do |standard|    
          unless @content.act_standards.include?(standard) 
           @content.act_standards << standard
            end
          end 
        @content_object_group = params[:content_object_type][:content_object_type_group].to_i
        ready = true
        if @content_object_group == 4  then
          @content.content_object_type = ContentObjectType.find_by_content_object_type("HTML")
            if params[:object][:embed].empty?
              ready = false
              @content.errors.add_to_base("NO EMBED CODE")
            else
              new_embed = params[:object][:embed]
              @content.content_object = new_embed.gsub(/width="\d+/, 'width="500').gsub(/height="\d+/, 'height="405')
            end
          elsif @content_object_group == 5
            @content.content_object = params[:object][:link]            
            @content.content_object_type = ContentObjectType.find_by_content_object_type("LINK")
            if @content.content_object.empty? || !@content.content_object.match(/^((http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?)*$/)
              ready = false
              @content.errors.add_to_base("INVALID LINK")
            end
          elsif !@content.source_file_file_name.blank?

              @content.content_object_type = ContentObjectType.find_by_content_object_type(@content.source_file_file_name.match(/\.[\w]+/).to_s.match(/\w+/).to_s) rescue nil
          else
              ready = false
              @content.content_object_type = nil
              @content.errors.add_to_base("No Source File File Name ")          
        end
        if @content_object_group == 2
          @content.source_file_preview = params[:content][:source_file]
        end
        @content.except_terms_or_service_vaild = true
        if ready
          if @content.content_object_type then
            if @content_object_group != @content.content_object_type.content_object_type_group_id then 
              ready = false
              @content.errors.add_to_base("Invalid File Type ") 
            end
          else
              ready = false
              @content.errors.add_to_base("Invalid File Type ")         
          end
        end
        
        if ready
          if @content.save then
            @current_user.add_as_favorite_to(@content) 
#           flash[:notice] =   "SAVED!Title: #{@content.title} object_group #{@content_object_group} content_object #{@content.content_object}  source file #{@content.source_file_content_type}source file file name #{@content.source_file_file_name} File SIZE: #{@content.source_file_file_size} Preview File name #{@content.source_file_preview_file_name} CONTENT OBJECT TYPE  #{type} "
            redirect_to  :controller => "site/site", :action => "static_resource", :organization_id => @current_organization, :id => @content
          end
        end
        @content.errors.add_to_base("  RESELECT YOUR RESOURCE")
        flash[:error] = @content.errors.full_messages.to_sentence       
      end
    end
  end

  def destroy_selected

    initialize_std_parameters
   
   @current_organization = Organization.find_by_public_id(params[:organization_id])
   @destroy_count = 0
   params[:res_check] ||= []
   params[:res_check].each do |r|
     res = Content.find_by_id(r)rescue nil
     unless res.nil?
        user_list = res.leaders_using
        if res.destroy
          @destroy_count +=1
          unless !@current_organization.content_notify?        
            user_list.each do |ldr|
              if ldr || ldr != @current_user
                Notifier.deliver_resource_destroyed(:user => ldr,:current_user=>@current_user,:current_organization => @current_organization, :title => res.title, :content => res, :fsn_host => request.host_with_port)
              end
            end
          end
        end
     end
   end
   flash[:notice] = "Resources Permanently Purged" 
   redirect_to :action => 'index', :organization_id => @current_organization , :current_group=>params[:current_group].titleize
  end
 
   
  def manage_resources

  end
 
 
  def edit_resource
    
    initialize_std_parameters
    
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    ready = true
    updated = false     
    @content = Content.find_by_public_id(params[:content_id])rescue nil
    orig_title = @content.title
    if @content then
      if params[:function] == "Submit"
        @new_resource = @current_organization.contents.new(params[:content])

 #
 #      New Source File?
 #           
        if params[:content][:source_file] then
          @new_resource.content_object_type = ContentObjectType.find_by_content_object_type(@new_resource.source_file_file_name.match(/\.[\w]+/).to_s.match(/\w+/).to_s) rescue nil
          if @new_resource.content_object_type.nil?
            ready = false
            @content.errors.add_to_base("New File Type Invalid")
          elsif @new_resource.content_object_type.content_object_type_group_id != @content.content_object_type.content_object_type_group_id then
            ready = false
            @content.errors.add_to_base("New File Type Invalid") 
          else
            @content.content_object_type_id = @new_resource.content_object_type_id
            if @content.content_object_type.content_object_type_group_id == 2
              @content.source_file_preview = params[:content][:source_file]      
            end
          end
        else
        # No new file  
      end
 #
 #      New Preview File?
 #           
      if params[:content][:source_file_preview] then      
        object_type = ContentObjectType.find_by_content_object_type(@new_resource.source_file_preview_file_name.match(/\.[\w]+/).to_s.match(/\w+/).to_s) rescue nil
        if object_type then 
          if object_type.content_object_type_group_id != 2
            ready = false
            @content.errors.add_to_base("New Preview File Type Invalid")
          else
            #preview File Type OK
          end  
        else
          ready = false
          @content.errors.add_to_base("New Preview File Type Invalid")            
        end
      else
      # No Preview File
      end 
#
#  Make Sure New Embed Code Not Blank
#      
      if @content.content_object_type.content_object_type_group_id == 4
        if params[:object][:embed].empty?
          ready = false
          @content.errors.add_to_base("NO EMBED CODE")
        else
          new_embed = params[:object][:embed]
          @content.content_object = new_embed.gsub(/width="\d+/, 'width="500').gsub(/height="\d+/, 'height="405')
        end 
      end
#
#  Make Sure New Link is Valid
#      
      if @content.content_object_type.content_object_type_group_id == 5
        if @new_resource.content_object.empty? || !@new_resource.content_object.match(/^((http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?)*$/)
          ready = false
          @content.errors.add_to_base("INVALID LINK")
        end 
      end            
      
      if ready then
       unless params[:content][:subject_area_id].empty?
         subject_area = SubjectArea.find_by_id(params[:content][:subject_area_id])rescue nil
         if subject_area
           @content.subject_area_old = subject_area.name
           @content.subject_area_id = subject_area.id
           @content.act_subject_id = subject_area.act_subject_id
         end
       end
       unless params[:content][:content_resource_type_id].empty?
         resource_type = ContentResourceType.find_by_id(params[:content][:content_resource_type_id])rescue nil
         if resource_type
           @content.resource_type = resource_type.name
           @content.content_resource_type = resource_type
         end
       end
#
#  Content Score Range Updates

          if params[:c_range]
            existing_range = @content.act_score_ranges.for_standard(@current_standard).first rescue nil
            new_range = ActScoreRange.find_by_id(params[:c_range][:act_score_range_id]) rescue nil
            if existing_range && new_range
              unless @content.act_score_ranges.include?(new_range) 
                @content.act_score_ranges.delete existing_range
                @content.act_score_ranges << new_range
              end            
            end
          end

#
#  Content Standards Updates

        params[:add_check] ||= []
        std_list = []
        params[:add_check].each do |s|
        std = ActStandard.find_by_id(s)rescue nil
          unless std.nil?
            std_list<<std
            end
          end        
        std_list.uniq.each do |standard|    
          unless @content.act_standards.include?(standard) 
           @content.act_standards << standard
            end
        end
        params[:del_check] ||= []
        std_list = []
        params[:del_check].each do |s|
        std = ActStandard.find_by_id(s)rescue nil
          unless std.nil?
           @content.act_standards.delete std rescue nil
            end
          end              

       
       @content.except_terms_or_service_vaild = true
       @content.title = params[:new_title][:title]
       user_list = @content.leaders_using       
        if @content.update_attributes(params[:content]) then
          @content.update_attribute("updated_by", @current_user.id)
          usr_count = 0
          if @content.organization.content_notify?        
            user_list.each do |ldr|
              if ldr || ldr != @current_user
                Notifier.deliver_resource_updated(:user => ldr,:current_user=>@current_user,:current_organization => @current_organization, :title => @content.title, :content => @content, :fsn_host => request.host_with_port)
                usr_count += 1
              end
            end
          end
          flash[:notice] = "#{@content.title.upcase} Updated, #{usr_count.to_s} Users Notified "
          updated = true
        else
          flash[:error] = @content.errors.full_messages.to_sentence
        end
      else

        flash[:error] = @content.errors.full_messages.to_sentence
      end
    else
    # No Submission - passthru
    end         
  else
    flash[:error] = "Resource No Longer Exists."
    updated = true
  end  
  if updated
    redirect_to(:controller => 'site/site',:action => "static_resource", :organization_id => @current_organization, :id => @content)
  end
 end

  def edit_assess
    
    initialize_std_parameters

    @content = Content.find_by_public_id(params[:content_id]) rescue nil
    @mastery_range = @content.act_score_ranges.for_standard(@current_standard).first rescue nil
    @strands = @content.act_standards.for_standard(@current_standard) rescue nil
    

    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    if @content.act_subject_id
      @current_subject = ActSubject.find_by_id(@content.act_subject_id)
    end
  end
  
  def user_resources
    
    initialize_std_parameters

   @resource_list = @current_user.administrator_of?(@current_organization) ? Content.find(:all, :include => :content_resource_type, :conditions => ["organization_id = ? AND content_resource_types.name = ?", @current_organization.id, params[:type]]) : Content.find(:all, :include => :content_resource_type, :conditions => ["user_id = ? AND organization_id = ? AND content_resource_types.name = ?", @current_user.id, @current_organization.id, params[:type]])
   @resource_list.sort!{|a,b| b.updated_at <=> a.updated_at}
  end
 

  
  def select_subject_areas
    subjects = SubjectArea.auto_complete_on params[:q]
    render :text => subjects.empty? ? "" : subjects.collect{|subject| "#{subject.name}\n"}
  end
  
  def select_resource_types
    rtypes = ContentResourceType.auto_complete_on params[:q]
    render :text => rtypes.empty? ? "" : rtypes.collect{|rtype| "#{rtype.name}\n"}
  end
 
  protected

 def initialize_parameters 
       
 end
  
 def initialize_std_parameters 
    if @current_user
      @current_standard = @current_user.act_master
    else
      @current_standard = ActMaster.find(:first)
    end     
 end

  def content_groupings
    @content_groups = []
    @content_groups[0] = "folder"
    @content_groups[1] = "type" 
  end


end