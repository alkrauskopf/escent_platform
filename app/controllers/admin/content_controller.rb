class Admin::ContentController < Admin::ApplicationController   
  skip_before_filter :verify_authenticity_token    
  layout false
  
  def search 
    @features = Topic.features
    if request.xhr?
      @keywords = params[:keywords]
      @contents = (@current_organization.contents.with_keywords @keywords, :organization => @current_organization).paginate :per_page => 10, :page => params[:page]
      render :template => "/admin/content/#{params[:render_html]}"      
    end  
  end
  
  def search_with_type
    @features = Topic.features    
    if request.xhr?
      if params[:keywords].blank?
        @contents = [].paginate :per_page => 10, :page => params[:page]
      else
        contents_list = @current_organization.contents.active.with_keywords_and_type params[:keywords], params[:type], :organization => @current_organization
        session[:content_ids] = (session[:content_ids].blank? ? contents_list.collect{|c| c.id} : (session[:content_ids] & contents_list.collect{|c| c.id}))
        @contents = Content.find(session[:content_ids]).paginate :per_page => 10, :page => params[:page]
      end
      render :template => "/admin/content/#{params[:render_html]}"
    end  
  end
  
  def list_pending_x
    content_upload_source = ContentUploadSource.find_by_name("call to action")
    @contents = (@current_organization.contents.active.with_content_upload_source content_upload_source.id).paginate :per_page => 10, :page => params[:page]
    render :template => "/admin/content/list_pending_page" if params[:page]
  end
  
  def show
    if request.xhr?
      @content = Content.find_by_public_id(params[:id])
      # respond_to do |wants|
      #   wants.html { render :template => "/admin/content/show" } 
      # end  
    end
  end
  
  
  def show_favorites
    if request.xhr?
      @user = User.find_by_public_id(params[:user_id])
      @content = @user.favorite_resources
    end
  end
  
  
  def new
    @content = Content.new
  end
  
  def edit
    @content = Content.find_by_public_id(params[:content_id])
    @content_object_group = @content.content_object_type.content_object_type_group_id
  end
  
  def update
    @content = Content.find_by_public_id(params[:content_id])      
    
    unless @content.nil?      
        
      if @content.content_object_type.content_object_type_group_id == 4 then
          new_embed = params[:object][:embed]
          @content.content_object = new_embed.gsub(/width="\d+/, 'width="500').gsub(/height="\d+/, 'height="405')
      elsif @content.content_object_type.content_object_type_group_id == 5
        @content.content_object = params[:object][:link]
        @content.content_object_type = ContentObjectType.find_by_content_object_type("LINK")
      elsif @content.content_object_type.content_object_type_group_id == 2
        @content.source_file_preview = params[:content][:source_file]      
       end
      @content.except_terms_or_service_vaild = true
      
      if @content.update_attributes(params[:content]) then
        @content.update_attribute("updated_by", @current_user.id)
        @contents = @current_organization.contents.paginate :per_page => 10, :page => params[:page]
        
        responds_to_parent do  
          render :update do |page|
            page.replace_html 'content_panel', :file => 'admin/content/index', :object => @contents
          end
        end
      else

        flash[:error] = @content.errors.full_messages.to_sentence
        
        responds_to_parent do  
          render :update do |page|
            page.replace_html 'content_panel', :file => 'admin/content/new'
          end
          
        end
      end      
    else
      responds_to_parent do  
        render :update do |page|
          page.replace_html 'content_panel', :file => 'admin/content/new'
        end
        
      end
    end
  end
  
  def index
    @features = Topic.features    
    @contents = []
    @contents = @current_organization.contents.paginate :per_page => 10, :page => params[:page]
    render :template => "/admin/content/search_results" if params[:page]
  end
  
  def create
    @features = Topic.features 
    if request.post?
      @content = @current_organization.contents.new(params[:content])
      @content.user = @current_user 
       unless params[:content][:content_resource_type_id].empty?
         resource_type = ContentResourceType.find_by_id(params[:content][:content_resource_type_id])rescue nil
         if resource_type
           @content.resource_type = resource_type.name
           @content.content_resource_type = resource_type
         end
       end
         
      if @content_object_group == "" then 
        flash[:error] = "You must select your content's Type before submitting"
        
        responds_to_parent do  
          render :update do |page|
            page.replace_html 'content_panel', :file => 'admin/content/new'
          end
        end
      else
        @content_object_group = params[:content_object_type][:content_object_type_group].to_i

        if @content_object_group == 4  then
          new_embed = params[:object][:embed]
          @content.content_object = new_embed.gsub(/width="\d+/, 'width="500').gsub(/height="\d+/, 'height="405')
          @content.content_object_type = ContentObjectType.find_by_content_object_type("HTML")
          #@content.content_object = params["content_editor"]
        elsif @content_object_group == 5
          @content.content_object = params[:object][:link] 
          @content.content_object_type = ContentObjectType.find_by_content_object_type("LINK")
          #@content.content_object = params["content_link_text"]
        else
          @content.content_object_type = ContentObjectType.find_by_content_object_type(@content.source_file_file_name.match(/\.[\w]+/).to_s.match(/\w+/).to_s) unless @content.source_file_file_name.blank?
        end
        
        @content.except_terms_or_service_vaild = true
        
        if @content_object_group == 2
          @content.source_file_preview = params[:content][:source_file]
        end
        
        if @content.save then
          @current_user.add_as_favorite_to(@content) 
          @contents = @current_organization.contents.paginate :per_page => 10, :page => params[:page]
          flash[:notice] = "Saved: #{@content.title}"
          
          responds_to_parent do  
            render :update do |page|
              page.replace_html 'content_panel', :file => 'admin/content/index', :object => @contents
            end
          end
        else

          flash[:error] = @content.errors.full_messages.to_sentence
          
          responds_to_parent do  
            render :update do |page|
              page.replace_html 'content_panel', :file => 'admin/content/new'
            end
          end
        end        
      end
    end
  end
  
  def delete
    @content = Content.find_by_public_id(params[:content_id])
    @content.make_as_delete
    redirect_to :action => :index
  end
  
  def destroy_anyway
    @content = Content.find_by_public_id(params[:content_id])
    @content.destroy
    redirect_to :action => :index
  end
  
  def destroy_x
    @content = Content.find_by_public_id(params[:content_id])
    @content.destroy if @content.pending?
    content_upload_source = ContentUploadSource.find_by_name("call to action")
    @contents = (@current_organization.contents.active.with_content_upload_source content_upload_source.id).paginate :per_page => 10, :page => params[:page]
    render :action => :list_pending
  end


# ALK Addition for Subject Area & Resource Type Autocompletion
  def select_subject_areas
    subjects = SubjectArea.auto_complete_on params[:q]
    render :text => subjects.empty? ? "" : subjects.collect{|subject| "#{subject.name}\n"}
  end
  
  def select_resource_types
    rtypes = ContentResourceType.auto_complete_on params[:q]
    render :text => rtypes.empty? ? "" : rtypes.collect{|rtype| "#{rtype.name}\n"}
  end
  
end
