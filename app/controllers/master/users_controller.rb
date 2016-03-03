class Master::UsersController < Master::ApplicationController
  layout "crud"
  
  before_filter :find_user, :only => [:edit, :show, :delete, :toggle_su, :toggle_suspend]
  
  def index
    if params[:sort_by] == "la"
      @users = User.by_last_logon_asc 
    elsif params[:sort_by] == "ld"
      @users = User.by_last_logon_desc 
    elsif params[:sort_by] == "ra"
      @users = User.by_register_asc
    elsif params[:sort_by] == "rd"
      @users = User.by_register_desc
    elsif params[:sort_by] == "nd"
      @users = User.by_name_desc
    else
      @users = User.by_name_asc
    end 
  end
  
  def new
    @user = User.new
    if request.post?
      @user = User.new(params[:user])
      if @user.save
        flash[:notice] = "Successfully created user #{@user.full_name}."
        redirect_to :action => :index
      else
        flash[:error] = @user.errors.full_messages.to_sentence
      end
    end
  end

  def toggle_su
    if request.post?
      if @user.superuser?
        su_auths = @user.authorizations.superuser
        su_auths.destroy_all
      else
       su = Authorization.new
       su.authorization_level_id = AuthorizationLevel.superuser.id
       su.user_id = @user.id
       su.save   
      end
    end
    redirect_to :action => :index
  end
 
 
  def toggle_suspend
    if request.post?
      unless @user.superuser?
        @user.suspend(!@user.suspended?)  
      end
    end
    redirect_to :action => :index
  end
  
  def edit
    if request.post?
      if @user.update_attributes(params[:user])
          flash[:notice] = "Successfully updated user #{@user.full_name}."
          redirect_to :action => :index
      else
        flash[:error] = @user.errors.full_messages.to_sentence
      end
    end
  end
  
  def show
  end
  
  def delete
    if request.post?
      Authorization.destroy_all( ["scope_type = ? AND scope_id = ?", "User", @user.id])
      @user.destroy
      flash[:notice] = "Successfully removed user #{@user.full_name}."
      redirect_to :action => :index
    end
  end

  def reset_emails
    User.all.each do |user|
      user.update_attributes(:preferred_email =>"alkrauskopf@gmail.com", :Phone_for_Texting => nil)
    end
     redirect_to :action => :index
  end

  
  protected
  
  def find_user
    @user = User.find(params[:id])
  end  
end
