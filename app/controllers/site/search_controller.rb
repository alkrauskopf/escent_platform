class Site::SearchController < ApplicationController
  helper :all # include all helpers, all the time
  layout "search"

  before_filter :search_authorized?

  def search
    search_params
    filter_ids
    #   People Search
    if @search_type == "People"
      order_by ||= "last_name, first_name"
      if @keywords.nil?
        items_found = User.active.order(order_by)
      else
        items_found = User.active.with_names @keywords, :order => order_by
      end
      people_filters(items_found)
      items_found = filter_people(items_found)
    elsif @search_type == "Organizations"
      order_by ||= "name"
      if @keywords.nil?
        items_found = Organization.active.order(order_by)
      else
        items_found = Organization.active.with_names @keywords, :order => order_by
      end
      org_filters(items_found)
      items_found = filter_orgs(items_found)
    elsif @search_type == "Offerings"
      order_by = "course_name"
      if @keywords.nil?
        items_found = Classroom.active.all(:include => :subject_area, :order => "subject_areas.name")
      else
        items_found = Classroom.active.with_course_names @keywords, :order => order_by
      end
      offering_filters(items_found)
      items_found = filter_offerings(items_found)
    elsif @search_type == "Resources"
      order_by = "title"
      if @keywords.nil?
        items_found = Content.available_to_user(@current_user)
      else
        items_found = Content.available_to_user_with_keywords(@current_user, @keywords, @current_organization, order_by)
      end
      resource_filters(items_found)
      items_found = filter_resources(items_found)
    else
      items_found = []
    end
    @items_size = items_found.size
    @items_found = items_found.paginate(:per_page => 15, :page => params[:page])
    @page = params[:page]? params[:page].to_i : 1
    if params[:page]
      render :layout => false
    end
  end

  private

  def search_params
    @keywords = (params[:keywords] && params[:keywords] != '') ? params[:keywords].delete("?*(+[|\\") : nil
    @search_type = (params[:search] && params[:search][:type] != '') ? params[:search][:type] : @search_entities[0]
    @search_type = params[:page_search] ? params[:page_search] : @search_type
  end

  def filter_ids
    if params[:filter]
      @filter_resource_strand_id = params[:filter][:r_strand] ? params[:filter][:r_strand].to_i : nil
      @filter_resource_subject_id = params[:filter][:r_subject] ? params[:filter][:r_subject].to_i : nil
      @filter_people_org_id = params[:filter][:p_org] ? params[:filter][:p_org].to_i : nil
      @filter_org_type_id = params[:filter][:o_type] ? params[:filter][:o_type].to_i : nil
      @filter_offering_subject_id = params[:filter][:c_subject] ? params[:filter][:c_subject].to_i : nil
    else
      @filter_resource_strand_id = params[:page_resource_strand_filter_id] ? (params[:page_resource_strand_filter_id]).to_i : nil
      @filter_resource_subject_id = params[:page_resource_subject_filter_id] ? (params[:page_resource_subject_filter_id]).to_i : nil
      @filter_people_org_id = params[:page_people_org_filter_id] ? params[:page_people_org_filter_id].to_i : nil
      @filter_org_type_id = params[:page_org_type_filter_id] ? params[:page_org_type_filter_id].to_i : nil
      @filter_offering_subject_id = params[:page_offering_subject_filter_id] ? params[:page_offering_subject_filter_id].to_i : nil
    end
  end

  def resource_filters(items_found)
    strand_list = items_found.map{|i| i.strands.select{|s| !s.act_subject.nil? && s.active?}}.compact.flatten.uniq.sort_by{|s| s.act_subject.name}
    @resource_strand_filters =  strand_list.collect{|s| [(s.act_subject.name + ' | ' + s.name), s.id]} << ['All Strands', 0]
    subject_list = items_found.map{|i| i.subject_area}.compact.flatten.uniq.sort_by{|s| s.name}
    @resource_subject_filters =  subject_list.collect{|s| [s.name, s.id]} << ['All Subjects', 0]
  end

  def people_filters(items_found)
    org_list = items_found.map{|i| i.organization}.compact.uniq.sort_by{|o| o.short_name}
    @people_org_filters =  org_list.collect{|o| [o.name, o.id]} << ['All Organizations', 0]
  end

  def org_filters(items_found)
    type_list = items_found.map{|i| i.organization_type}.compact.uniq.sort_by{|t| t.name}
    @org_type_filters =  type_list.collect{|t| [t.name, t.id]} << ['All Types', 0]
  end

  def offering_filters(items_found)
    subject_list = items_found.map{|i| i.subject_area}.compact.flatten.uniq.sort_by{|s| s.name}
    @offering_subject_filters =  subject_list.collect{|s| [s.name, s.id]} << ['All Subjects', 0]
  end

  def filter_resources(items_found)
    @search_filters = []
    if @filter_resource_strand_id
      strand = ActStandard.find_by_id(@filter_resource_strand_id) rescue nil
      items_found = strand.nil? ? items_found : items_found.select{|r| r.strands.include?(strand)}
      if !strand.nil?
        @search_filters << strand.abbrev
      end
    end
    if @filter_resource_subject_id
      subject = SubjectArea.find_by_id(@filter_resource_subject_id) rescue nil
      items_found = subject.nil? ? items_found : items_found.select{|r| r.for_subject?(subject)}
      if !subject.nil?
        @search_filters << subject.name
      end
    end
    items_found
  end

  def filter_people(items_found)
    @search_filters = []
    if @filter_people_org_id
      organization = Organization.find_by_id(@filter_people_org_id) rescue nil
      items_found = organization.nil? ? items_found : items_found.select{|i| i.organization == organization}
      if !organization.nil?
        @search_filters << organization.short_name
      end
    end
    items_found
  end

  def filter_orgs(items_found)
    @search_filters = []
    if @filter_org_type_id
      org_type = OrganizationType.find_by_id(@filter_org_type_id) rescue nil
      items_found = org_type.nil? ? items_found : items_found.select{|i| i.organization_type == org_type}
      if !org_type.nil?
        @search_filters << org_type.name
      end
    end
    items_found
  end

  def filter_offerings(items_found)
    @search_filters = []
    if @filter_offering_subject_id
      subject = SubjectArea.find_by_id(@filter_offering_subject_id) rescue nil
      items_found = subject.nil? ? items_found : items_found.select{|r| r.for_subject?(subject)}
      if !subject.nil?
        @search_filters << subject.name
      end
    end
    items_found
  end
end

