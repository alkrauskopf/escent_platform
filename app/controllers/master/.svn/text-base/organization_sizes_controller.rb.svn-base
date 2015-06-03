class Master::OrganizationSizesController < Master::ApplicationController
  # GET /organization_sizes
  # GET /organization_sizes.xml
  def index
    @organization_sizes = OrganizationSize.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @organization_sizes }
    end
  end

  # GET /organization_sizes/1
  # GET /organization_sizes/1.xml
  def show
    @organization_size = OrganizationSize.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organization_size }
    end
  end

  # GET /organization_sizes/new
  # GET /organization_sizes/new.xml
  def new
    @organization_size = OrganizationSize.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @organization_size }
    end
  end

  # GET /organization_sizes/1/edit
  def edit
    @organization_size = OrganizationSize.find(params[:id])
  end

  # POST /organization_sizes
  # POST /organization_sizes.xml
  def create
    @organization_size = OrganizationSize.new(params[:organization_size])

    respond_to do |format|
      if @organization_size.save
        flash[:notice] = 'OrganizationSize was successfully created.'
        format.html { redirect_to(@organization_size) }
        format.xml  { render :xml => @organization_size, :status => :created, :location => @organization_size }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @organization_size.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /organization_sizes/1
  # PUT /organization_sizes/1.xml
  def update
    @organization_size = OrganizationSize.find(params[:id])

    respond_to do |format|
      if @organization_size.update_attributes(params[:organization_size])
        flash[:notice] = 'OrganizationSize was successfully updated.'
        format.html { redirect_to(@organization_size) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organization_size.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /organization_sizes/1
  # DELETE /organization_sizes/1.xml
  def destroy
    @organization_size = OrganizationSize.find(params[:id])
    @organization_size.destroy

    respond_to do |format|
      format.html { redirect_to(organization_sizes_url) }
      format.xml  { head :ok }
    end
  end
end
