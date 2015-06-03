class Master::ReligiousAffiliationsController < Master::ApplicationController

  before_filter :find_religious_affiliation, :only => [:edit, :show, :delete]

  def index
    @religious_affiliations = ReligiousAffiliation.find :all
    @root = ReligiousAffiliation.find_by_name("root")
  end

  def show
  end

  def new
    @religious_affiliation = ReligiousAffiliation.new
    if request.post?
      @religious_affiliation = ReligiousAffiliation.new(params[:religious_affiliation])
      if @religious_affiliation.save  
        flash[:notice] = "Successfully created #{@religious_affiliation.name}."
        redirect_to :action => :index
      else
        flash[:error] = @religious_affiliation.errors.full_messages.to_sentence
      end
    end
  end

  def delete
    if request.post?
      @religious_affiliation.destroy
      flash[:notice] = "Successfully removed #{@religious_affiliation.name}."
      redirect_to :action => :index
    end
  end

  def edit
    if request.post?
      if @religious_affiliation.update_attributes(params[:religious_affiliation])
          flash[:notice] = "Successfully updated #{@religious_affiliation.name}."
          redirect_to :action => :index
      else
        flash[:error] = @religious_affiliation.errors.full_messages.to_sentence
      end
    end
  end

  protected
  
  def find_religious_affiliation
    @religious_affiliation = ReligiousAffiliation.find(params[:id])
  end  

end