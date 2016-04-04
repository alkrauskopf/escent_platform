class Apps::LearningTimeStandardsController  < Site::ApplicationController

  helper :all  # include all helpers, all the time
  layout "elt", :except =>[]


  before_filter :elt_allowed?, :except=>[]
  before_filter :current_org_current_app_provider?, :except=>[]
  before_filter :current_user_app_admin?, :except => []
  before_filter :clear_notification, :except => [:index, :edit_element]

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
    set_standard
    if @standard.update_attributes(:name => params[:name], :abbrev => params[:abbrev] )
      flash[:notice] = nil
    else
      flash[:error] = @standard.abbrev + ' Update Not Successful'
    end
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def edit
  end

  def destroy
    set_standard
    @standard.destroy
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def toggle_active
    set_standard
    @standard.update_attributes(:is_active => !@standard.is_active )
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def toggle_public
    set_standard
    @standard.update_attributes(:is_public => !@standard.is_public )
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def new_element
    set_standard
    @element = EltElement.new
  end

  def create_element
    set_standard
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
    set_element
    @element.update_attributes(:is_active => !@element.is_active )
  #  render :partial => "manage_standard_elements", :locals=>{:standard => element.standard}
    @standards = EltStandard.org_available(@current_organization)
    render :partial => "manage_standards"
  end

  def edit_element
    set_element
    @standard = @element.standard
  end

  def update_element
    set_element
    if @element.update_attributes(params[:elt_element])
      flash[:notice] = nil
    else
      flash[:error] = set_element.abbrev + ' Update Not Successful'
    end
    redirect_to :action => :index, :organization_id=>@current_organization
  end

  def new_indicator
    set_element
    @indicator = EltStdIndicator.new
    @indicator.position = @element.indicators.size + 1
  end

  def create_indicator
    set_element
    @indicator = EltStdIndicator.new(params[:elt_std_indicator])
    if !@element.nil?
      if @element.indicators << @indicator
        flash[:notice] = "#{@element.abbrev} Indicator Created"
      else
        flash[:error] = @indicator.errors.full_messages
      end
    else
      flash[:error] = 'Undefined Element'
    end
    redirect_to :action => :edit_element, :elt_element_id => @element, :organization_id => @current_organization
  end

  def toggle_indicator_active
    set_indicator
    @indicator.update_attributes(:is_active => !@indicator.is_active )
    render :partial => "manage_element_indicators", :locals=>{:element => @indicator.element}
  end

  def edit_indicator
    set_indicator
    @element = @indicator.element
  end

  def update_indicator
    set_indicator
    if @indicator.update_attributes(params[:elt_std_indicator])
      flash[:notice] = "#{@indicator.element.abbrev} Indicator Updated"
    else
      flash[:error] = "#{@indicator.element.abbrev} Indicator Not Updated"
    end
    redirect_to :action => :edit_element, :elt_element_id => @indicator.element, :organization_id => @current_organization
  end

  def update_descriptor
    set_indicator
    set_descriptor
    if !@descriptor.nil?
      if @descriptor.update_attributes(:position => params[:pos].to_i, :description => params[:descript])
        flash[:notice] = "Descriptor #{@descriptor.position} Updated"
      else
        flash[:error] = @descriptor.errors.full_messages
      end
    else
      @descriptor = EltStdDescriptor.new
      @descriptor.position = params[:pos].to_i
      @descriptor.description = params[:descript]
      if @indicator.descriptors << @descriptor
        flash[:notice] = "Descriptor #{@descriptor.position} Added"
      else
        flash[:error] = @descriptor.errors.full_messages
      end
    end
    render :partial => "apps/learning_time_standards/indicator_descriptors", :locals=>{:indicator => @indicator}
  end

  def destroy_descriptor
    set_descriptor
    @indicator = @descriptor.indicator
    @descriptor.destroy
    render :partial => "apps/learning_time_standards/indicator_descriptors", :locals=>{:indicator => @indicator}
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

  def set_indicator
    @indicator = EltStdIndicator.find_by_public_id(params[:elt_std_indicator_id])
  end

  def set_descriptor
    @descriptor = EltStdDescriptor.find_by_public_id(params[:elt_std_descriptor_id]) rescue nil
  end

end
