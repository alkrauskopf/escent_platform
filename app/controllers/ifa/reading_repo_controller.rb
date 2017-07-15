class Ifa::ReadingRepoController < Ifa::ApplicationController

  layout "ifa_repo", :except=>[]

  before_filter :current_user_app_authorized?
  before_filter :current_user_app_admin?, :only=>[]
  before_filter :current_app_superuser
  before_filter :current_user_app_admin
  before_filter :clear_notification, :except => []

  def index
    active_subjects
    active_genres
    @function = 'Create'
    @current_reading = ActRelReading.new
  end

  def create
    active_subjects
    active_genres
    @current_genre = params[:act_genre_id] ? ActGenre.find_by_id(params[:act_genre_id]) : ActGenre.find_by_id(params[:genre][:id]) rescue nil
    @current_subject = params[:act_subject_id] ? ActSubject.find_by_id(params[:act_subject_id]) : ActSubject.find_by_id(params[:subject][:id]) rescue nil
    @current_reading = ActRelReading.new
    @current_reading.act_subject_id = params[:subject][:id] != '' ? params[:subject][:id] : (@current_subject.nil? ? nil : @current_subject.id)
    @current_reading.act_genre_id = params[:genre][:id] != '' ? params[:genre][:id] : (@current_genre.nil? ? nil : @current_genre.id)
    @current_reading.label = params[:act_rel_reading][:label]
    @current_reading.reading = params[:act_rel_reading][:reading]
    @current_reading.organization_id = @current_organization.id
    if @current_user.act_rel_readings << @current_reading
      flash[:notice] = 'Reading Created'
      @function = 'Update'
    else
      flash[:error] = @current_reading.errors.full_messages.to_sentence
      @function = 'Create'
    end
    render :index
  end

  def edit
    active_subjects
    active_genres
    @function = 'Update'
    current_reading
    render :index
  end

  def update
    active_subjects
    active_genres
    current_reading
    @current_reading.act_subject_id = params[:subject][:id] != '' ? params[:subject][:id] : @current_reading.act_subject_id
    @current_reading.act_genre_id = params[:genre][:id] != '' ? params[:genre][:id] : @current_reading.act_genre_id
    @current_reading.label = params[:act_rel_reading][:label]
    @current_reading.reading = params[:act_rel_reading][:reading]
    if @current_reading.save
      flash[:notice] = 'Reading Update'
    else
      flash[:error] = @current_reading.errors.full_messages.to_sentence
    end
    @function = 'Update'
    render :index
  end

  def destroy
    current_reading
    @current_reading.destroy
    reading_pool
    render :partial =>  "reading_list"
  end

  def reading_list
    reading_pool
    render :partial =>  "reading_list"
  end

  def show
    current_reading
    render :layout => "assessment"
  end

  private


  def active_subjects
    @active_subjects = ActSubject.all_subjects
  end

  def current_subject
    @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
  end

  def current_reading
    @current_reading = ActRelReading.find_by_id(params[:act_reading_id]) rescue nil
  end

  def active_genres
    @active_genres = ActGenre.active
  end

  def reading_pool
    get_entity
    @entity_readings = @current_entity.act_rel_readings
  end

  def get_entity
    if params[:entity_class] && params[:entity_class] == 'User'
      @current_entity = User.find_by_id(params[:entity_id]) rescue nil
    elsif params[:entity_class] && params[:entity_class] == 'ActSubject'
      @current_entity = ActSubject.find_by_id(params[:entity_id]) rescue nil
    else
      @current_entity = nil
    end
  end

end
