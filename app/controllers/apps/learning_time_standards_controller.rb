class Apps::LearningTimeStandardsController  < Site::ApplicationController

  helper :all  # include all helpers, all the time
  layout "elt", :except =>[]


  before_filter :elt_allowed?, :except=>[]
  before_filter :current_org_current_app_provider?, :except=>[]
  before_filter :current_user_app_admin?, :except => []
  before_filter :clear_notification, :except => [:index]

  def index
    @standards = EltStandard.org_available(@current_organization)
    @standard = EltStandard.new
  end

  def create
    @standard = EltStandard.new(params[:elt_standard])
    if @current_organization.elt_standards << @standard
      flash[:notice] = "#{@standard.abbrev} Created"
    else
      flash[:error] = @standard.errors.full_messages
    end
    redirect_to :action => :index, :organization_id=>@current_organization
  end

  def update
    if set_standard.update_attributes(:name => params[:name], :abbrev => params[:abbrev] )
      flash[:notice] = nil
    else
      flash[:error] = set_standard.abbrev + ' Update Not Successful'
    end
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def edit
  end

  def destroy
    set_standard.destroy
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def toggle_active
    set_standard.update_attributes(:is_active => !set_standard.is_active )
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def toggle_public
    set_standard.update_attributes(:is_public => !set_standard.is_public )
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def new_element
    @standard = set_standard
    @element = EltElement.new
  end

  def create_element
    @standard = set_standard
    @element = EltElement.new(params[:elt_element])
    if !@standard.nil?
      if @standard.elements << @element
        flash[:notice] = "#{@element.abbrev} Created"
      else
        flash[:error] = @element.errors.full_messages
      end
    else
      flash[:error] = 'Undefined Standard'
    end
    redirect_to :action => :index, :organization_id=>@current_organization
  end

  def toggle_element_active
    element = set_element
    element.update_attributes(:is_active => !element.is_active )
  #  render :partial => "manage_standard_elements", :locals=>{:standard => element.standard}
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def edit_element
    @element = set_element
    @standard = @element.standard
  end

  def update_element
    if set_element.update_attributes(params[:elt_element])
      flash[:notice] = nil
    else
      flash[:error] = set_element.abbrev + ' Update Not Successful'
    end
    redirect_to :action => :index, :organization_id=>@current_organization
  end

  def maintain_element
    @task = params[:task]
    if @framework && params[:function] && params[:function] == "New"
      @element = EltElement.new(params[:elt_element])
      @element.is_active = false
      @element.organization_id = @current_organization.id
      @element.elt_framework_id = @framework.id
      @element.form_background = (params[:elt_element][:form_background].empty? ? "#FFFFFF" : params[:elt_element][:form_background]).upcase
      @element.i_form_background = (params[:elt_element][:i_form_background].empty? ? "#FFFFFF" : params[:elt_element][:i_form_background]).upcase
      @element.e_font_color = (params[:elt_element][:e_font_color].empty? ? "#000000" : params[:elt_element][:e_font_color]).upcase
      @element.abbrev = params[:elt_element][:abbrev].upcase
      @element.position = params[:elt_element][:position].to_i
      if @element.save
        flash[:notice] = "Successfully created element.   CLOSE WINDOW"
      else
        flash[:error] = @element.errors.full_messages.to_sentence
      end
    elsif params[:task] == "Update"
      @element = EltElement.find_by_public_id(params[:elt_element_id]) rescue nil
      unless @element.nil?
        if params[:function] && params[:function] == "Update"
          params[:elt_element][:form_background] = params[:elt_element][:form_background].upcase
          params[:elt_element][:i_form_background] = params[:elt_element][:i_form_background].upcase
          params[:elt_element][:e_font_color] = params[:elt_element][:e_font_color].upcase
          params[:elt_element][:abbrev] = params[:elt_element][:abbrev].upcase
          if @element.update_attributes(params[:elt_element])
            flash[:notice] = "Successfully Updated.   CLOSE WINDOW"
          else
            flash[:error] = @element.errors.full_messages.to_sentence
          end
        end
        if !@element.nil? && params[:function] && params[:function] == "Destroy"
          if @element.destroy
            flash[:notice] = "Element Destroyed.   CLOSE WINDOW"
            @element = EltElement.new
            @task = "New"
          else
            flash[:error] = @element.errors.full_messages.to_sentence
          end
        end
      else
        @element = EltElement.new
      end
    else
      @element = EltElement.new
    end
  end

  private

  def elt_allowed?
    @current_application = CoopApp.elt
    current_app_enabled_for_current_org?
  end

  def set_standard
    @standard = EltStandard.find_by_public_id(params[:elt_standard_id])
  end

  def standard_params
    params.require(:elt_standard).permit(
        :name, :abbrev, :is_public, :is_active
    )
  end

  def set_element
    @element = EltElement.find_by_public_id(params[:elt_element_id])
  end

end
