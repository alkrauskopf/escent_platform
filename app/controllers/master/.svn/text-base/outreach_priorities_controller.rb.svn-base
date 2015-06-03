class Master::OutreachPrioritiesController < Master::ApplicationController
  layout "master"

  before_filter :find_outreach_priority, :only => [:edit, :show, :delete]

  def index
  end

  def show
  end

  def new
    @outreach_priority = OutreachPriority.new
    if request.post?
      @outreach_priority = OutreachPriority.new(params[:outreach_priority])
      if @outreach_priority.save  
        flash[:notice] = "Successfully created outreach priority #{@outreach_priority.name}."
        redirect_to :action => :index
      else
        flash[:error] = @outreach_priority.errors.full_messages.to_sentence
      end
    end
  end

  def delete
    if request.post?
      @outreach_priority.destroy
      flash[:notice] = "Successfully removed outreach priority #{@outreach_priority.name}."
      redirect_to :action => :index
    end
  end

  def edit
    if request.post?
      if @outreach_priority.update_attributes(params[:outreach_priority])
          flash[:notice] = "Successfully updated outreach priority #{@outreach_priority.name}."
          redirect_to :action => :index
      else
        flash[:error] = @outreach_priority.errors.full_messages.to_sentence
      end
    end
  end

  protected
  
  def find_outreach_priority
    @outreach_priority = OutreachPriority.find(params[:id])
  end  

end