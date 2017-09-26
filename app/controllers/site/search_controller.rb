class Site::SearchController < ApplicationController
  helper :all # include all helpers, all the time
  layout "search"

  before_filter :search_authorized?

  def search
    search_params
    #   People Search
    if @search_type == "People"
      order_by ||= "last_name, first_name"
      if @keywords.nil?
        items_found = User.active.order(order_by)
      else
        items_found = User.active.with_names @keywords, :order => order_by
      end
    elsif @search_type == "Organizations"
        order_by ||= "name"
        if @keywords.nil?
          items_found = Organization.active.order(order_by)
        else
          items_found = Organization.active.with_names @keywords, :order => order_by
        end
    elsif @search_type == "Offerings"
      order_by = "course_name"
      if @keywords.nil?
        items_found = Classroom.active.all(:include => :subject_area, :order => "subject_areas.name")
      else
        items_found = Classroom.active.with_course_names @keywords, :order => order_by
      end
    elsif @search_type == "Resources"
      order_by = "title"
      if @keywords.nil?
        items_found = Content.available_to_user(@current_user)
      else
        items_found = Content.available_to_user_with_keywords(@current_user, @keywords, @current_organization, order_by)      end
    else
      items_found = []
    end
    @items_size = items_found.size
    @items_found = items_found.paginate(:per_page => 15, :page => params[:page])
    if params[:page]
      render :layout => false
 #     render :partial => 'search_results', :locals => {:items => @items_found, :items_size => @items_size,
 #                                                    :search_type => @search_type, :keywords => @keywords}
    end
  end

  private

  def search_params
    @keywords = (params[:keywords] && params[:keywords] != '') ? params[:keywords].delete("?*(+[|\\") : nil
    @search_type = (params[:search] && params[:search][:type] != '') ? params[:search][:type] : @search_entities[0]
    @search_type = params[:page_search] ? params[:page_search] : @search_type
  end
end
