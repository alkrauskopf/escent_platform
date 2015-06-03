class Admin::OutreachPriorityController < Admin::ApplicationController
  before_filter :load_data
  
  def new
    render :update do |page|
      page.replace_html "create_group_div" , :partial => "new"
    end
  end
  
  def create
    @outreach_priority_group.outreach_priorities = @outreach_priority_group.outreach_priority_obj
    @outreach_priority_group.valid?
    render :update do |page|
      if @outreach_priority_group.errors.blank?
        @outreach_priority_group.save
        page.insert_html :after , "insert_group" , :partial => "/admin/outreach_priority/show"
        page.replace_html "create_group_div" , ""
      else
        page.replace_html "group_error_message" , error_messages_for(:outreach_priority_group)
      end
    end
  end
  
  def edit
    render :update do |page|
      page.replace_html "create_group_div" , :partial => "edit"
    end
  end
  
  def update
    OutreachPriorityGroups.transaction do 
      @outreach_priority_group.attributes = params[:outreach_priority_group]
      @outreach_priority_group.outreach_priorities = @outreach_priority_group.outreach_priority_obj
      @outreach_priority_group.valid?
      render :update do |page|
        if @outreach_priority_group.errors.blank?
          @outreach_priority_group.save
          page.replace "group_#{@outreach_priority_group.public_id}" , :partial => "/admin/outreach_priority/show"
          page.replace_html "create_group_div" , ""
        else
          page.replace_html "group_error_message" , error_messages_for(:outreach_priority_group)
        end
      end
    end
  end
  
  def destroy
    @outreach_priority_group.destroy
    render :update do |page|
      page.remove "group_#{@outreach_priority_group.public_id}"
      page.replace_html "create_group_div" , ""
    end
  end
  
  def add_outreach_priority
    params[:outreach_priority_check] ||= []
    render :update do |page|
      params[:outreach_priority_check].each do |value|
        @outreach_priority = OutreachPriority.find(value) rescue nil
        if @outreach_priority.present?
          page << "if (!document.getElementById('out_pro_#{@outreach_priority.id}')){"
          page.insert_html :bottom , "add_group_outreach_priority" , :partial => "/admin/outreach_priority/outreach_priority_show"
          page << "}"
        end
      end
    end
  end
  
  def remove_outreach_priority
    params[:remove_outreach_priority] ||= []
    render :update do |page|
      params[:remove_outreach_priority].each do |value|
        page.remove "out_pro_#{value}"
      end
    end
  end
  
private  
  def load_data
    @outreach_priority_group = OutreachPriorityGroups.find_by_public_id(params[:outreach_priority_group_id]) rescue nil || OutreachPriorityGroups.new(params[:outreach_priority_group])
  end
  
end
