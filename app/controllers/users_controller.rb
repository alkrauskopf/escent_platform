class UsersController < ApplicationController
  layout "site"
  
  before_filter :current_organization
  before_filter :current_user, :only => [:edit_user_bio, :member_public_profile, :remove_this_organization, :add_this_organization, :toggle_favorite_organization, :add_this_colleague, :remove_this_colleague, :add_this_favorite_resource, :remove_this_favorite_resource, :add_this_favorite_classroom, :toggle_favorite_classroom, :edit_picture, :edit_profile, :change_home_org ,:sort_authorizations, :change_password, :remove_association, :edit_talents, :favorite_of]
  protect_from_forgery :except => [:sort_authorizations, :login]
 
  before_filter :clear_notification
  
  def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end
  
  
  def register
    if request.get?
      @user = User.new
    else
      @user = User.new params[:user]
      
        if User.find_by_email_address(@user.email_address).nil?
          @user.verification_code = User::generate_password(16)
          @user.set_default_registration_values(@current_organization.id)         
          
          if true #simple_captcha_valid?
            if @user.save
     #  Initialize First User as Superuser
              if User.all.size == 1
                @user.make_superuser!
              end

              @user.add_as_friend_to(@user.organization)
              #   temp omit Notifier.deliver_user_registration(:user => @user,:current_organization => @current_organization, :fsn_host => request.host_with_port)
              #            Notifier.deliver_user_registration @user, @current_organization, request.host_with_port
              #            Notifier.deliver_user_activate @user , url_for(:action => "activate" , :email => @user.email_address)

              if @user.organization.register_notify?
                @user.organization.administrators.each do |adm|
                  Notifier.deliver_admin_notice(:user => @user, :admn => adm, :user_organization => @user.organization, :fsn_host => request.host_with_port)
                end
              end
              redirect_to :action => :registration_successful, :organization_id => @current_organization,:user => @user
              return
            else
             # create_test_org
            #  @user.errors.add_to_base("REGISTRATION FAILED. ")
              @user.errors.add_to_base(@user.errors.full_messages.to_sentence)
            end
          else
            flash[:error] = @user.errors.full_messages.to_sentence
         #   flash[:error] << "  CAPTCHA Failed" if !simple_captcha_valid?
             @user.errors.add_to_base("CAPTCHA Mis-match. ")
          end
        else
           @user.errors.add_to_base("A user exists for " + @user.email_address)        
#          flash[:error] = "A user exists for " + @user.email_address  
         end 
     flash[:error] = @user.errors.full_messages.to_sentence
    end
    @home_organization_list = Organization.active.sort_by{|o| o.name}
    render :layout => "registration"
  end
  
  #  def activate
  #    @user = User.find_by_email_address(params[:email]) if params[:email].present?
  #    if @user.present?
  #      @user.status = "actived"
  #      @user.save
  #      Notifier.deliver_user_registration @user, request.host_with_port
  #    end
  #    render :layout => "fsn"
  #  end
  
  def registration_successful
    @user = User.find_by_public_id(params[:user])
    render :layout => "fsn"    
  end
  
  def verify
    @user = User.find_by_verification_code(params[:id])

    
    if @user
      @user.set_verified
 #    self.current_user = @user if @user.verified?
 #      redirect_to :action => :verified, :organization_id => @current_organization
      redirect_to :controller => "/site/site", :action => :static_organization, :organization_id => @user.home_organization
    else
      flash[:error] = "Verification code is not valid."      
    end
  end
  
  def edit_profile
    @user = @current_user
    if @user.bio
      @user_bio = @user.bio.description
    else
      @user_bio = "No Bio"
    end
    @talents = @user.talents
    order_by = params[:sort] || "headerSortUp"
 # 3.x upgrade bypass paginate problem for now
 # @authorizations = Authorization.friend_with_org_name(@user, order_by).paginate :page => params[:page], :per_page => 10
    @authorizations = Authorization.friend_with_org_name(@user, order_by)
    if request.post?
  #  if params[:commit] && params[:commit] = 'Submit Profile'

      valid_input = true
# 
# This contorted logic verifies uniqueness of alt_login.
# This is because validates_uniqueness of causes error with "Country" .Inexplicable.
      
      alias_id = params[:user][:alt_login]
      other_user = User.find_by_alt_login(alias_id)rescue nil
      unless alias_id.blank? || other_user.nil? || other_user == @user 
        valid_input = false
       @user.errors.add_to_base("A user exists for alias: " + alias_id)
      end
 
      phil_words = params[:user][:philosophy].split
      cred_words = params[:user][:credentials].split
      phil_words.each do |w|
        if w.length > 50 then
          valid_input = false
          @user.errors.add_to_base("A Philosophy Word Is Too Long")
        end
      end
      cred_words.each do |w|
        if w.length > 50 then
          valid_input = false
          @user.errors.add_to_base("A Credential Word Is Too Long")
        end
      end
      if valid_input
        if @user.update_attributes(params[:user])
          flash[:notice] = "Profile Updated Successfully"
        else
          flash[:error] = @user.errors.full_messages.to_sentence
        end
      else
        flash[:error] = @user.errors.full_messages.to_sentence
      end
    end
  end
    
  def edit_user_bio
    @user = User.find_by_public_id(params[:user_id]) rescue nil
    if @user && params[:update]
      unless @user.bio
        @bio = Bio.new(params[:bio])  
        if @user.bio = @bio       
          flash[:notice] = "Bio Created"       
        else
          flash[:error] = @user.bio.errors.full_messages.to_sentence 
        end
      else
        if @user.bio.update_attributes(params[:bio])   
          flash[:notice] = "Bio Updated"       
        else
          flash[:error] = @user.bio.errors.full_messages.to_sentence 
        end
        @bio = @user.bio
      end
    else
      @bio = @user && @user.bio ? @user.bio : Bio.new
    end
  end
    
  def change_home_org
    @user = @current_user
    org = Organization.find_by_id(params[:user][:home_org_id]) rescue nil
    if org && @user.update_attributes(:home_org_id => params[:user][:home_org_id], :organization_id => params[:user][:home_org_id])
       @user.add_as_friend_to(org)       
       flash[:notice] = "Profile Updated Successfully"       
    else
       flash[:error] = @user.errors.full_messages.to_sentence 
     end
  redirect_to :controller => 'users', :action => 'edit_profile', :organization_id => @current_organization
  end
  
  def sort_authorizations
    @user = @current_user    
    if request.xhr?
      order_by = params[:sort] || "headerSortUp"
      @authorizations = Authorization.friend_with_org_name(@user, order_by).paginate :page => params[:page], :per_page => 10
      render :partial => "associations", :locals => {:show_remove => true, :header => order_by}, :layout => false and return
    end
  end
  
  def show
    @user = User.find_by_public_id params[:id]
    render :layout => false 
  end
  
  def member_public_profile
    
    @user = User.find_by_public_id params[:id]
    if @user.nil? 
      then @user = User.all.first
    end
    @owned_classrooms = @user.owned_classrooms
    @classroom_favs = @user.favorite_classrooms
    @classroom_lead = @user.lead_classrooms
    @classroom_participate = @user.participate_classrooms
    @colleagues = @user.colleagues
    @resource_favs = @user.viewable_favorite_resources(@current_user ? @current_user : nil)
 #   @org_connects =  @user.authorizations.find(:all,:conditions=>"scope_type LIKE 'Organization'",:order => :scope_id, :group => :scope_id)
  #  @org_connects =  @user.authorizations.org_connections
    @org_connects = @user.favorite_organizations
    @followers = @user.followers
    
    render :layout => "site"
#    render :layout => "public_info"
  end
  
  def login
#    find_featured_topic
    if request.post?
     if user = User.authenticate(params[:login_id], params[:user][:password])
 #       if user = User.all.first
        user.set_logon_date
        if user.verified_at.nil?
          flash[:unverified] = true
          flash[:login_error] = "User not verified"
          respond_to do |format|
            format.html { redirect_to :back }
            format.js { render :action => :login }
          end          
        elsif (user.is_suspended? && params[:user][:password] != "ep_demo")
          flash[:suspended] = true
          flash[:login_error] = "User Suspended"
          respond_to do |format|
            format.html { redirect_to :back }
            format.js { render :action => :login }
          end
        else
  #        self.current_user = user
          session[:user_id] = user.id
          if request.xhr?
            render :file => "/users/login.js" and return                      
          end
          if flash[:redirect].nil?
            respond_to do |format|
            format.html { redirect_to :back }
            format.js { render :action => :login }
            end
 #           redirect_to :controller => "site/site", :action => "static_organization", :id => @current_organization.public_id
          else
            redirect_to :controller => :organizations,  :action => flash[:redirect]
          end
        end        
      else
        flash[:login_error] = "Sign-in Unsuccessful"   
        respond_to do |format|
          format.html { redirect_to :back }
          format.js { render :action => :login }
        end
      end
    end
  end
  
  def logout
    return_org = @current_organization
    unless self.current_user.nil?
     unless self.current_user.organization.nil?
       return_org = self.current_user.organization
     end
    end
#    self.current_user = nil
    session.delete(:user_id)
    session[:viewed] = nil
    flash[:notice] = 'Logged out'
    redirect_to :controller => "site/site", :action => "static_organization", :organization_id => return_org
  end
  
  def add_this_organization
#    @current_user.add_as_friend_to(@current_organization) unless @current_user.has_authorization_level_for?(@current_organization, "friend")
    @current_user.add_as_friend_to(@current_organization) unless @current_user.has_authority?(AuthorizationLevel.app_friend(CoopApp.core), @current_organization)
    redirect_to :back
end

  def remove_this_organization
    @organization = Organization.find_by_public_id(params[:organization_id])
    unless @organization.nil? 
      @current_user.remove_as_friend_from @organization 
    end
    redirect_to :back
 end  

  def toggle_favorite_organization
    @organization = Organization.find_by_public_id(params[:organization_id])
    unless @organization.nil? 
      if @current_user.favorite_organizations.include?(@organization)
        @current_user.remove_as_friend_from @organization 
      else
       @current_user.add_as_friend_to(@organization) 
      end
    end
    redirect_to :back
 end

  
  def add_this_colleague
    @user = User.find(params[:user_id])rescue nil
    unless @user.nil?
    @current_user.add_as_colleague_to(@user) unless @current_user.colleagues.include?(@user)
    end
    redirect_to :back  
  end
 
   def remove_this_colleague
    @user = User.find(params[:user_id])rescue nil
    unless @user.nil?
      if @current_user.colleagues.include?(@user)
        @current_user.remove_as_colleague_from(@user)
      end
    end
    redirect_to :back  
  end  

 def toggle_favorite_classroom
    @classroom = Classroom.active.find(params[:classroom_id])rescue nil
    unless @classroom.nil?
      @current_user.toggle_classroom_favorite(@classroom)
    end
    redirect_to :back  
 end
  
 def add_this_favorite_resource
    @content= Content.active.find(params[:content_id])rescue nil
    unless @content.nil?    
 #     @current_user.add_as_favorite_to(@content) unless @current_user.has_authorization_level_for?(@content, "favorite")
      @current_user.add_as_favorite_to(@content) unless @current_user.has_authority?(AuthorizationLevel.app_favorite(CoopApp.core), @content)
    end
   redirect_to :back  
 end

  
  def remove_this_favorite_resource
   @content= Content.active.find(params[:content_id]) rescue nil
   unless @content.nil?   
 #   if @current_user.has_authorization_level_for?(@content, "favorite")
    if @current_user.has_authority?(AuthorizationLevel.app_favorite(CoopApp.core), @content)
      @current_user.remove_as_favorite_from(@content)
    end
   end
   redirect_to :back  
 end

  def assign_standard_view
    @current_user = User.find_by_public_id params[:id]
    master = ActMaster.find_by_public_id(params[:view])
    @current_user.set_standard_view(master)
   redirect_to :back  
 end
  
  def forgot_password
    @user = nil
    new_pass = nil
    if request.post?
      user = User.with_email(params[:user][:email_address]).first rescue nil
      unless user
        user = User.with_alt_login(params[:user][:email_address]).first rescue nil        
      end
      if user
        new_pass = user.reset_password
      end
      if new_pass
        Notifier.deliver_reset_password(:user => user, :password => new_pass, :fsn_host => request.host_with_port)
        flash[:notice]  = "New password sent to <strong>" + user.preferred_email + "</strong>. Give it a few minutes. Check SPAM."
      else
        flash[:error]  = "Couldn't Generate Password. Correct ID? <strong>" + params[:user][:email_address].to_s + "</strong>"  
      end
    @user = user
    end
    render :layout => "fsn"
  end
  
  def change_password
    @user = @current_user
    
    if request.post?
      if !params[:user][:password].blank? && !params[:user][:password_confirmation].blank?
        if @user.update_attributes(params[:user])
          flash[:notice] = "Password changed"        
        else
          flash[:error] = @user.errors.full_messages.to_sentence        
        end
      else
        flash[:error] = "Please enter a new password"
      end
      redirect_to :controller => "users",  :action => "edit_profile", :organization_id => @current_organization                        
    end   
  end
  
  def remove_association
    # should we also delete the roles?
    #role = @current_user.roles.find params[:id]
    # @current_user.roles.delete(role)
    
    @organization = Organization.find params[:org_to_delete]
    @current_user.remove_as_friend_from @organization 
    flash[:notice] = "#{@current_user.full_name} has been removed from this organization"
    redirect_to :controller => "users", :action => "edit_profile", :organization_id => @current_organization
  end
  
  def view
    redirect_to :controller => "site",  :action => params[:organization_id]
  end
  
  def check_talent_name
    talents = Talent.auto_complete_on params[:q]
    render :text => talents.empty? ? "" : talents.collect{|talent| "#{talent.name}\n"}
  end
  
  def edit_talents
    if request.post?
      update_talents(params[:talents]) if params[:talents]
      flash[:notice] = "Successfully saved talents."
      redirect_to :controller => "users",  :action => "edit_profile", :organization_id => @current_organization
    end
  end
  
  def remove_talent
    talent = Talent.find(params[:id])
    Talent.destroy(talent)
    render :text => "successful"
  end

  def edit_picture
    if params[:user].present? && params[:user][:picture].present?
      @current_user.picture = params[:user][:picture]
      if @current_user.save
        flash[:notice] = 'Uploaded picture successfully'
      else
        flash[:notice] = 'Upload failed'
      end
    else
      flash[:error] = "Picture can't be blank"
    end
    redirect_to :controller => 'users', :action => 'edit_profile', :organization_id => @current_organization
  end
  
  private
  
  def find_featured_topic
    if params[:topic_id]
      @current_topic = Topic.find_by_public_id params[:topic_id]
    else
      @current_topic = @current_organization.featured_topic || @current_organization.topics.active.first
    end
    @content = @current_topic ? @current_topic.contents.first : nil
    @related_content = @current_topic ? @current_topic.contents[1,@current_topic.contents.size] : []
    @other_active_topics = @current_organization.topics.active.collect{|t| t} - [@current_organization.featured_topic || @current_organization.topics.active.first]
  end  
  
  def update_talents(talents) 
    talents[:id].each_with_index do |id, i|
      talent_attributes = {:name => talents[:name][i]}
      begin
        if id.blank?
          @current_user.talents.create(talent_attributes) unless talents['name'].blank? || talents['name'].nil?
        else
          @current_user.talents.find(talents[:id][i]).update_attributes(talent_attributes)
        end
      rescue ActiveRecord::StatementInvalid => e
        flash[:error] = 'some error happen'
      end
    end    
  end


  def create_test_org
    @org = Organization.new
    @org.name = 'Tester Organization'
    @org.organization_type_id = 2
    @org.web_site_url = 'http://www.google.com'
    @org.status_id = 1
    @org.phone = '303-250-0436'
    @org.organization_size_id = 2
    @org.contact_name = 'ALKrauskopf'
    @org.contact_role = 'King'
    @org.default_address_id = 1
    @org.contact_email = 'akrauskopf@precisionschoolimprovement.com'
    @org.contact_phone = '303-250-0436'
    @org.include_information = true
    @org.is_default = false
    @org.nick_name = 'Tester'
    @org.alt_short_name = 'Tester'
    @org.display_contact = true
    @org.save
  end


end
