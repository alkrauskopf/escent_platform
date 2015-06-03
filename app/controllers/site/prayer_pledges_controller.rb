class Site::PrayerPledgesController < Site::ApplicationController
  
  protect_from_forgery :except => [:join, :invite_friend]  
  
  layout "prayer_pledge"
  
  def index  
    redirect_to :action => "register_en"
  end
  
  def register_en
    @organization = (Organization.find_by_public_id(params[:organization_id]) rescue Organization.default)
    # @prayer_pledge = @organization.prayer_pledges.new(params[:prayer_pledge])
    get_or_create
    if request.post? &&  @prayer_pledge.save
      session[:prayer_pledge_id] = @prayer_pledge.id
      Notifier.deliver_successful_pledge_en @prayer_pledge.email_address, request.host_with_port, @prayer_pledge
      redirect_to "http://www.odysseynetworks.org/Causes/Peace/tabid/178/Default.aspx"      
      # redirect_to :action => "join", :id => @prayer_pledge
    end
  end
  
  def register_es
    @organization = (Organization.find_by_public_id(params[:organization_id]) rescue Organization.default)
    # @prayer_pledge = @organization.prayer_pledges.new(params[:prayer_pledge])
    get_or_create
    if request.post? &&  @prayer_pledge.save
      session[:prayer_pledge_id] = @prayer_pledge.id
      Notifier.deliver_successful_pledge_es @prayer_pledge.email_address, request.host_with_port , @prayer_pledge
      redirect_to "http://www.odysseynetworks.org/Causes/Peace/tabid/178/Default.aspx"
    end    
  end
  
  def join
    @prayer_pledge = PrayerPledge.find session[:prayer_pledge_id]
    @user = User.find_by_email_address(@prayer_pledge.email_address)
    if request.post? && @prayer_pledge.update_attributes(params[:prayer_pledge])
      if params[:prayer_pledge][:allow_me_to_particapte] == "1"
        PrayerPledge.update_or_create_user(@prayer_pledge, params[:prayer_pledge])
        @prayer_pledge.user.verification_code = User::generate_password(16)
        @prayer_pledge.user.save
        Notifier.deliver_user_registration @prayer_pledge.user, request.host_with_port
      end
      invite_friend if params[:invite_friend] == "1"
      redirect_to :action => "successful"
    else
      render :action => "join"
    end
  # rescue
  #   redirect_to :action => "register"
  end
  
  def successful
    @prayer_pledge = PrayerPledge.find session[:prayer_pledge_id]
    redirect_to "http://www.odysseynetworks.org/Causes/Peace/tabid/178/Default.aspx"
  end
  
  
  private
  
  def get_or_create
    @prayer_pledge = @organization.prayer_pledges.new(params[:prayer_pledge])      
    if request.get? && @current_user
      @prayer_pledge.first_name = @current_user.first_name
      @prayer_pledge.last_name = @current_user.last_name
      @prayer_pledge.email_address = @current_user.email_address
      @prayer_pledge.email_address_confirmation = @current_user.email_address_confirmation
      @prayer_pledge.country = @current_user.country
    end
  end
  
  def invite_friend
    sender_emails = params[:email_archive][:sender_email].split(/, */)
    sender_emails.each do |sender_email|
      @current_organization.metrics << Metric.new(:share_type => 4 ,:user_id => @current_user)
      Notifier.deliver_invite_friend(:organization => @prayer_pledge.organization, :user => @prayer_pledge, :sender_email => sender_email, :message => params[:email_archive][:plain_body])
    end
  end    
end
