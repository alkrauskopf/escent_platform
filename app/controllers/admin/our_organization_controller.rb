class Admin::OurOrganizationController < Admin::ApplicationController
  layout "admin/our_organization/layout", :except =>[:update_logo]
  include ApplicationHelper
  # include SimpleCaptcha::ControllerHelpers
  
#  include OrganizationRegistration


  before_filter :clear_notification

  def index
  #  redirect_to :action => :profile, :organization_id => @current_organization
  end
  
  def information
  end

  def update_profile
    @organization = @current_organization
    @address = @organization.addresses.first || @organization.addresses.new
    flash[:notice] = nil
    if request.post?
      if @organization.update_attributes params[:organization]
        @address.organization = @organization
        if !@address.update_attributes params[:address]
          flash[:error] = @address.errors.full_messages.to_sentence
        else
          flash[:notice] = "Organization Information Updated:  ", @organization.name
        end
      else
        flash[:error] = @organization.errors.full_messages.to_sentence
      end
    end
    redirect_to admin_path(:organization_id => @current_organization)
  end


  def update_include_information
     @current_organization.include_information = params[:include_information] || true
     @current_organization.save
     render :nothing => true
  end


  def toggle_notification
     if @current_organization.organization_core_option
        if params[:registration]
          @current_organization.organization_core_option.update_attributes(:register_notify => !@current_organization.organization_core_option.register_notify)
        end
        if params[:content]
          @current_organization.organization_core_option.update_attributes(:content_notify => !@current_organization.organization_core_option.content_notify)
        end      
     else
       @current_organization.organization_core_option = OrganizationCoreOption.new
     end
    render :partial => "registration_notify"
  end


  def toggle_registration_allow
    @current_organization.update_attributes(:can_register => !@current_organization.can_register)
    render :partial => "registration_allow"
  end
  
  def update_logo_x
    @current_organization.logo = params[:organization][:logo]
    if @current_organization.save then
      flash[:notice] = "Logo Saved"      
    else
      flash[:error] = @current_organization.errors.full_messages.to_sentence
    end
 #   redirect_to admin_path(:organization_id => @current_organization)
    render :partial => "/admin/our_organization/organization_logo"
  end
  
  def update_body
    @current_organization.body = params[:org_body].to_s
    @current_organization.save
    render :update do |page|
      page.replace_html "organization_body" , to_br(@current_organization.body)
    end
  end
  
  def profile
    register
  end

  def registration_successful
    redirect_to :action => :profile, :organization_id => @current_organization
  end


  def appearance
    @color_style_settings = StyleSetting.colors
  end

  def branding

  end
  
  def options
    if request.post?
      if params[:organization]
        @current_organization.update_attributes params[:organization]
        respond_to do |format|
          format.js do
            responds_to_parent do
              render :update do |page|
                page.replace_html "affiliate_information_panel", :partial => 'affiliate_information', :object => @current_organization
              end
            end          
          end
        end
      else
        params[:sections].each do |key, value|
          page_section = @current_organization.page_sections.find_or_create_by_page_and_section("index", key)
          attributes = {:content_object => value, :content_object_type => ContentObjectType.html, :user_id => 1, :title => "index/#{key}"}
          if page_section.content
            page_section.content.update_attributes attributes
          else
            page_section.update_attributes :content => @current_organization.contents.create(attributes)
          end
        end
      end
    end
  end
  
  def topic
    
  end
  
  def reset_default_styles
    @current_organization.set_default_style_settings
    @color_style_settings = StyleSetting.colors    
#    render :partial => "organization_information"
    render :template => "admin/our_organization/appearance"
  end
  
  def update_style_setting_value
    @current_organization.update_style_settings(params)
    expire_page :controller => "/stylesheets", :action => :iwing, :organization_id => @current_organization
    render :text => ""
  end

  def change_style_setting
#  make sure org has all style settings set
    target_setting = Setting.find_by_id(params[:setting_id]) rescue nil
    if !target_setting.nil?
      StyleSetting.colors.each do |setting|
        if @current_organization.setting_values.for_setting(setting).first.nil?
          @current_organization.new_setting!(setting)
        end
        if setting == target_setting
          if @current_organization.setting_values.for_setting(setting).first.update_attributes(:value => params[:color].upcase)
            flash[:normal] = 'Setting Updated'
          else
            flash[:error] = 'Setting Not Updated'
          end
        end
      end
    else
      flash[:error] = 'Invalid Setting ID'
    end
    render :partial => 'organization_colors', :locals => {:organization => @current_organization}
  end

  def update_logo
    @current_organization.logo = params[:organization][:logo]
    if @current_organization.save then
      flash[:notice] = "Logo Saved"
    else
      flash[:error] = @current_organization.errors.full_messages.to_sentence
    end
       redirect_to admin_path(:organization_id => @current_organization)
#    render :partial => "organization_logo"
  #  redirect_to :controller=> 'admin/application',  :action => :index, :organization_id => @current_organization
  end

  def app_subscriptions
  end

  def coop_app_enable_disable
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    app = CoopApp.find_by_public_id(params[:app_id]) 
    provider_id = params[:provider_id] ? params[:provider_id].to_i : ((@current_organization.app_settings(app).nil? || @current_organization.app_settings(app).provider_id.nil?) ? app.providers.first.id : @current_organization.app_settings(app).provider_id)
    if @current_organization.app_settings(app).nil?
      create_app_settings(app, @current_organization, false, true, true, "", "", provider_id)
      @current_organization.set_org_options(app, true) 
    else
      switch_selected = !@current_organization.app_settings(app).is_selected
      update_app_settings(app, @current_organization, @current_organization.app_settings(app).is_owner, switch_selected , @current_organization.app_settings(app).is_allowed, @current_organization.app_settings(app).alt_abbrev,  @current_organization.app_settings(app).alt_name, provider_id)
      @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
      @current_organization.set_org_options(app, switch_selected)
    end

    render :partial => "admin/our_organization/coop_apps"
  end

  def edit_app_alt_name
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    app = CoopApp.find_by_public_id(params[:app_id]) rescue nil
    if params[:alt_name] && params[:alt_abbrev] && app && @current_organization.app_settings(app)
      @current_organization.app_settings(app).update_attributes(:alt_name => params[:alt_name], :alt_abbrev => params[:alt_abbrev].upcase)
    end
    render :partial => "admin/our_organization/provider_apps"
  end

  def provider_app_enable
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    org = Organization.find_by_id(params[:org_id])   
    app = CoopApp.find_by_public_id(params[:app_id]) 
    if org && app   
      if org.app_settings(app) 
        if org.app_settings(app).is_allowed && (org.app_settings(app).provider_id.nil? || org.app_settings(app).provider_id == @current_organization.id)
          if  org.app_settings(app).is_selected
            on_off = false
            provider_id = nil
            alt_abbrev = ''
            alt_name = ''
          else
            on_off = true
            provider_id = @current_organization.id
            alt_abbrev = @current_organization.app_settings(app).alt_abbrev
            alt_name = @current_organization.app_settings(app).alt_name
          end
          update_app_settings(app, org, org.app_settings(app).is_owner, on_off, org.app_settings(app).is_allowed, alt_abbrev, alt_name, provider_id)
          org = Organization.find_by_id(params[:org_id]) 
        end
      else
        create_app_settings(app, org, false, true, true, "", "", @current_organization.id)
        on_off = true
      end
      org.reset_org_option(app, on_off)
    end    
    render :partial => "admin/our_organization/provider_apps"
  end

  protected
 
end  
