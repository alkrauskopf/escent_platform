class Admin::ClassroomsController < Admin::ApplicationController
  layout "admin/classrooms/layout", :except =>[:view_classroom_members]
  
  before_filter :find_classroom, :except => [:index, :new, :create]
  
  layout false
  # GET /classrooms
  # GET /classrooms.xml
  def index
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    @active_classrooms = @current_organization.classrooms.active
    @archived_classrooms = @current_organization.classrooms.archived

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classrooms }
    end
  end

  # GET /classrooms/1
  # GET /classrooms/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classroom }
    end
  end

  # GET /classrooms/new
  # GET /classrooms/new.xml
  def new
    @classroom = @current_organization.classrooms.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @classroom }
    end
  end

  # GET /classrooms/1/edit
  def edit
  end

  # POST /classrooms
  # POST /classrooms.xml
  def create
    @classroom = @current_organization.classrooms.new(params[:classroom])
    unless params[:classroom][:subject_area_id].empty?
      subject_area = SubjectArea.find_by_id(params[:classroom][:subject_area_id])
      @classroom.subject_area_id = subject_area.id
      @classroom.act_subject_id = subject_area.act_subject_id
    end
    respond_to do |format|
      if @classroom.save
        @current_user.add_as_leader_to(@classroom)
        flash[:notice] = 'Classroom was successfully created.'
        format.html { redirect_to(:controller => 'admin/classrooms',:action => "index",:organization_id => @current_organization) }
        format.xml  { render :xml => @classroom, :status => :created, :location => @classroom }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @classroom.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classrooms/1
  # PUT /classrooms/1.xml
  def update
    unless params[:classroom][:subject_area_id].nil?
      subject_area = SubjectArea.find_by_id(params[:classroom][:subject_area_id])
      @classroom.subject_area_id = subject_area.id
      @classroom.act_subject_id = subject_area.act_subject_id
    end
    respond_to do |format|
      if @classroom.update_attributes(params[:classroom])
        flash[:notice] = 'Classroom was successfully updated.'
        format.html { redirect_to(:controller => 'admin/classrooms',:action => "index",:organization_id => @current_organization)}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classroom.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classrooms/1
  # DELETE /classrooms/1.xml
  def destroy
    @classroom.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => 'admin/classrooms',:action => "index",:organization_id => @current_organization) }
      format.xml  { head :ok }
    end
  end

  def archive
   @classroom.status = 'archived'
   @classroom.save
   redirect_to(:controller => 'admin/classrooms',:action => "index",:organization_id => @current_organization)
  end

  def restore
    @classroom.status = 'active'
    @classroom.save
    redirect_to(:controller => 'admin/classrooms',:action => "index",:organization_id => @current_organization)
  end

#
# Leader & particpator Methods
#
  def view_classroom_members
    @classroom = Classroom.find_by_public_id(params[:classroom_id])
    @al = AuthorizationLevel.find(params[:id])
    @people = @classroom.authorized_users.find_all_by_authorization_level_id(@al)
  rescue ActiveRecord::RecordNotFound => e
    render :text => "<div>No users found.</div>" and return
  end
  
  def remove_authorization_level
    user = User.find_by_public_id(params[:user_id])
    find_classroom
    authorization_level =  AuthorizationLevel.find(params[:authorization_level_id])
    user.authorizations.each do |a|
      a.destroy if (a.authorization_level == authorization_level && a.scope_id == @classroom.id)
    end
    flash[:notice] = "#{user.full_name} has been removed"
    redirect_to :action => :authorization_assignments, :classroom_id => @classroom, :organization_id => @current_organization
  end
  
  def authorization_assignments
    find_classroom
    @authorization_levels = AuthorizationLevel.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'favorite') AND applicable_scopes.name = ?", "Classroom"])  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classroom }
    end
  end

  def new_user_authorization
     @authorization_levels = AuthorizationLevel.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'favorite') AND applicable_scopes.name = ?", "Classroom"])    
     find_classroom
     @people = @current_organization.friends_of_org
    if request.post?
      user = User.find(params[:user])
      authorization_level = AuthorizationLevel.find(params[:authorization_level])
    if (user.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(@classroom, @classroom.class.to_s, authorization_level))
      redirect_to :action => :authorization_assignments, :classroom_id => @classroom, :organization_id => @current_organization
      else
        if user.authorizations.create :authorization_level => authorization_level, :scope => @classroom                      
        flash[:notice] = "Successfully added the user to authorization level: #{authorization_level.name}."
        redirect_to :action => :authorization_assignments,  :classroom_id => @classroom, :organization_id => @current_organization
        else
        flash[:notice] = "error"
        redirect_to :action => :authorization_assignments,  :classroom_id => @classroom, :organization_id => @current_organization
        end
      end
    end
  end
  
  
  
  
  private
  def find_classroom
    @classroom = @current_organization.classrooms.find_by_public_id(params[:classroom_id])    
  end
end
