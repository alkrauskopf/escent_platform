module OrganizationRegistration
  
  def register
    @initialize_master =  (User.all.empty? && Organization.all.empty?)
    redirect_to :action => :no_user, :id => "register" unless (@current_user || @initialize_master)
    
    if @current_organization.nil?
      @address = Address.new
      new
    else
      update
    end
  end
  
  def activate
    @organization = Organization.find_by_public_id(params[:public_id]) if params[:public_id].present?
    if @organization.present? && params[:email].present?
      @organization.status = Status.approved 
      @organization.save
    end
#    render :layout => "fsn"
  end
  
  def new
    if request.post? 
      @organization = Organization.new(params[:organization])
      @address = @organization.addresses.new(params[:address])
          
        if params[:accept_tos].nil?
          flash[:error] = "You must agree to the terms of service"
        else
          if params[:no_website].nil? && @organization.web_site_url.empty? then
            flash[:error] = "Website URL is required. If you do not have a website check the Don't have a Web Site checkbox."
          else
            if @address.save
              @organization.is_default = @initialize_master
              if  @organization.save
                @address.organization = @organization
                if @current_user then @current_user.add_as_administrator_to(@organization) end
                if @current_user then  @current_user.add_as_friend_to(@organization) end
                @organization.set_default_style_settings
                @address.organization_id = Organization.with_type_id(@organization.organization_type_id).select{|o| o.name == @organization.name}.last.id
                @address.save
                redirect_to :action => :registration_successful, :organization_id => @organization
              else
                @address.destroy
                flash[:error] = @organization.errors.full_messages.to_sentence
              end        
             else
            flash[:error] = @address.errors.full_messages.to_sentence
          end
 
        end 
      end
    else
      
      @organization = Organization.new()
      @organization.organization_type_id = nil
      @address = @organization.addresses.empty? ? @organization.addresses.new : @organization.addresses.physical.first
    end
  end
  
  def registration_successful
    @saved_org = Organization.find_by_public_id(params[:organization_id])
    if @saved_org
      create_app_settings(CoopApp.core, @saved_org, false, true, true, CoopApp.core.abbrev, CoopApp.core.name, CoopApp.core.providers.first.id)
      @saved_org.organization_core_option = OrganizationCoreOption.new
      flash[:normal] = @saved_org.name + ' Created'
    else
      flash[:error] = @saved_org.name + ' Created. But Setting & Options were not.  - Problem'
    end
    render :layout => "fsn"
  end
  
  def update
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
  end
 
  private


end
