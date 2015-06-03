class Admin::FundraisingCampaignsController < Admin::ApplicationController
  # GET /fundraising_campaigns
  # GET /fundraising_campaigns.xml
  def index
    @fundraising_campaigns = @current_organization.fundraising_campaigns
    render :layout => false
  end

  # GET /fundraising_campaigns/1
  # GET /fundraising_campaigns/1.xml
  def show
    @fundraising_campaign = @current_organization.fundraising_campaigns.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false }
      format.xml  { render :xml => @fundraising_campaign }
    end
  end

  # GET /fundraising_campaigns/new
  # GET /fundraising_campaigns/new.xml
  def new
    @fundraising_campaign = FundraisingCampaign.new

    respond_to do |format|
      format.html { render :layout => false }
      format.xml  { render :xml => @fundraising_campaign }
    end
  end

  # GET /fundraising_campaigns/1/edit
  def edit
    @fundraising_campaign = @current_organization.fundraising_campaigns.find(params[:id])
    render :layout => false
  end

  # POST /fundraising_campaigns
  # POST /fundraising_campaigns.xml
  def create
    @fundraising_campaign = @current_organization.fundraising_campaigns.new(params[:fundraising_campaign])
    @fundraising_campaign.merchant_account = @current_organization.merchant_account

    respond_to do |format|
      if @fundraising_campaign.save
        @fundraising_campaigns = @current_organization.fundraising_campaigns
        flash[:notice] = 'FundraisingObjective was successfully created.'
        format.html { redirect_to :controller => "application", :action => :index, :organization_id => @current_organization }
        format.js   { render :action => :index, :layout => false }
        format.xml  { render :xml => @fundraising_campaign, :status => :created, :location => @fundraising_campaign }
      else
        format.html { render :action => "new", :layout => false }
        format.xml  { render :xml => @fundraising_campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fundraising_campaigns/1
  # PUT /fundraising_campaigns/1.xml
  def update
    @fundraising_campaign = @current_organization.fundraising_campaigns.find(params[:id])

    respond_to do |format|
      if @fundraising_campaign.update_attributes(params[:fundraising_campaign])
        @fundraising_campaigns = @current_organization.fundraising_campaigns        
        flash[:notice] = 'FundraisingObjective was successfully updated.'
        format.html { redirect_to([:admin, @fundraising_campaign]) }
        format.js { render :action => :index, :layout => false }        
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fundraising_campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fundraising_campaigns/1
  # DELETE /fundraising_campaigns/1.xml
  def destroy
    @fundraising_campaign = @current_organization.fundraising_campaigns.find(params[:id])
    if @fundraising_campaign.can_be_deleted?
      @fundraising_campaign.destroy
    else
      flash[:error] = "This fundraising campaign cannot be deleted because there are linked payments"
    end
    
    respond_to do |format|
      format.html { redirect_to(admin_fundraising_campaigns_url) }
      format.xml  { head :ok }
    end
  end
end
