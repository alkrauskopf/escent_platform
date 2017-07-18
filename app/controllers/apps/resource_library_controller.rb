class Apps::ResourceLibraryController < ApplicationController

  helper :all # include all helpers, all the time

    layout "resource", :except=>[]

    before_filter :set_core, :except=>[]
    before_filter :current_user_app_authorized?, :except=>[]
    before_filter :current_user_km_authorized?, :only=>[]
    before_filter :current_standard
    before_filter :clear_notification, :except => []

  def index
    @current_entity = nil
    resource_pool
  end

  def pool_filter_select
    current_entity
    resource_pool
    render :partial =>  "/apps/resource_library/resource_pool_list"
  end

  def add
    current_group
    @current_resource = Content.new
    @function = 'Create'
  end

  def create
    current_group
    current_subject
    @current_resource = Content.new(params[:content])
    populate_params
    @current_resource.organization_id = @current_organization.id
    if @current_user.contents << @current_resource
      precision_prep_tags
      flash[:notice] = "Resource Saved | Add Another"
      @current_resource = Content.new
      @current_group = nil
    else
      flash[:error] = @current_resource.errors.full_messages.to_sentence
    end
    @function = 'Create'
    render 'add'
  end

  def destroy
    current_resource
    @current_resource.destroy
    current_entity
    resource_pool
    render :partial => "resource_pool_list"
  end

  def group_select
    current_group
    render :partial => "resource_group"
  end

  def prep_subject_select
    current_subject
    @current_level = nil
    render :partial => "resource_precision_prep"
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
      @content_org = @content.organization ? @content.organization : Organization.ep_default.first
    end

  private

  def populate_params
    @current_resource.title = params[:content][:title].nil? ? '': params[:content][:title]
    @current_resource.content_status_id = params[:content][:content_status_id].nil? ? ContentStatus.available.id : params[:content][:content_status_id]
    @current_resource.description = params[:content][:description]
    @current_resource.description = params[:content][:description]
    @current_resource.publish_start_date = Date.new(params[:content]['publish_start_date(1i)'].to_i, params[:content]['publish_start_date(2i)'].to_i, params[:content]['publish_start_date(3i)'].to_i)
    @current_resource.publish_end_date = Date.new(params[:content]['publish_end_date(1i)'].to_i, params[:content]['publish_end_date(2i)'].to_i, params[:content]['publish_end_date(3i)'].to_i)
    @current_resource.publish_end_date = (@current_resource.publish_start_date >= @current_resource.publish_end_date) ? (@current_resource.publish_start_date + 20.years) : @current_resource.publish_end_date
    @current_resource.source_url = params[:content][:source_url]
    @current_resource.source_name = params[:content][:source_name]
    @current_resource.caption = params[:content][:caption]
    @current_resource.target_score_range = params[:content][:target_score_range]
    @current_resource.subject_area_id = params[:content][:subject_area_id]
    @current_resource.content_resource_type_id = params[:content][:content_resource_type_id]
    @current_resource.content_status_id = params[:content][:content_status_id] == '' ? ContentStatus.available.id : params[:content][:content_status_id]
    @current_resource.terms_of_service = params[:content][:terms_of_service] == '1' ? true : false
    @current_resource.content_object_type_id = resource_object_type
    @current_resource.content_object = resource_object
    @current_resource.updated_by = @current_user.id
    @current_resource.act_subject_id = @current_subject ? @current_subject.id : nil
    if @current_resource.previewable? && params[:content][:source_file]
      @current_resource.source_file_preview =  params[:content][:source_file]
    end
    byebug
  end


  def resource_object_type
    type_id = nil
    if params[:object]
      if params[:object][:link]
        type_id = ContentObjectType.find_by_content_object_type("LINK").id rescue nil
      elsif params[:object][:embed]
        type_id = ContentObjectType.find_by_content_object_type("HTML").id rescue nil
      end
    elsif @current_resource.source_file.present?
      type_id = ContentObjectType.find_by_content_object_type(@current_resource.source_file_file_name.match(/\.[\w]+/).to_s.match(/\w+/).to_s.upcase).id rescue nil
    end
    type_id
  end

  def resource_object
    content_object = nil
    if params[:object]
      if params[:object][:link]
        content_object = params[:object][:link]
      elsif params[:object][:embed]
        content_object = params[:object][:embed]
      end
    end
    content_object
  end

  def precision_prep_tags
    @current_resource.act_standard_contents.destroy_all
    params[:strand_check].each do |strand_id|
      strand_join = ActStandardContent.new(:act_standard_id => strand_id)
      @current_resource.act_standard_contents << strand_join
    end
  end

  def current_group
    @current_group = ContentObjectTypeGroup.find_by_id(params[:group_id]) rescue nil
    @current_group ||= ContentObjectTypeGroup.find_by_id(params[:group][:type_id]) rescue nil
  end

  def current_subject
    @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
    @current_subject ||= ActSubject.find_by_id(params[:act_subject][:id]) rescue nil
  end

  def current_standard
    @current_standard = @current_organization.app_enabled?(CoopApp.ifa) ? @current_organization.app_provider(CoopApp.ifa).master_standard : nil
  end

  def current_entity
    if params[:entity_class] == 'User'
      @current_entity = User.find_by_id(params[:entity_id])
    elsif params[:entity_class] == 'ContentObjectTypeGroup'
      @current_entity = ContentObjectTypeGroup.find_by_id(params[:entity_id])
    elsif params[:entity_class] == 'ActSubject'
      @current_entity = ActSubject.find_by_id(params[:entity_id])
    else
      @current_entity = nil
    end
  end

  def knowledge_manager?
    @current_user.content_manager_for_org?(@current_organization)
  end

  def resource_pool
    @resource_pool = knowledge_manager? ? @current_organization.contents : @current_user.contents
    resource_pool_filters
    if !@current_entity.nil?
      if @current_entity.class.to_s == 'User'
        @resource_pool = @resource_pool.select{|r| r.user == @current_entity}.sort{|a,b| b.updated_at <=> a.updated_at}
      elsif @current_entity.class.to_s == 'ContentObjectTypeGroup'
        @resource_pool = @resource_pool.select{|r| r.content_group == @current_entity}.sort{|a,b| b.updated_at <=> a.updated_at}
      elsif @current_entity.class.to_s == 'ActSubject'
        @resource_pool = @resource_pool.select{|r| r.act_subject_id == @current_entity.id}.sort{|a,b| b.updated_at <=>a.updated_at}
      end
    end
  end

  def resource_pool_filters
    @pool_filters = {}
    @pool_filters['User'] = @resource_pool.map{|r| r.user}.compact.uniq.sort_by{|u| u.last_name}
    @pool_filters['Type'] = knowledge_manager? ? ContentObjectTypeGroup.all_by_name : ContentObjectTypeGroup.active
  end

    def initialize_std_parameters
      @standards = ActStandard.all.collect{|s|[s.standard]}.uniq.sort
    end
end
