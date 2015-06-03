class Master::MerchantAccountsController < Master::ApplicationController
  # GET /merchant_accounts
  # GET /merchant_accounts.xml
  def index
    @merchant_accounts = MerchantAccount.all
  end

  # GET /merchant_accounts/1
  # GET /merchant_accounts/1.xml
  def show
    @merchant_account = MerchantAccount.find(params[:id])
  end

  # GET /merchant_accounts/new
  # GET /merchant_accounts/new.xml
  def new
    @merchant_account = MerchantAccount.new
  end

  # GET /merchant_accounts/1/edit
  def edit
    @merchant_account = MerchantAccount.find(params[:id])
  end

  # POST /merchant_accounts
  # POST /merchant_accounts.xml
  def create
    @merchant_account = MerchantAccount.new(params[:merchant_account])
    if @merchant_account.save
      flash[:notice] = 'MerchantAccount was successfully created.'
      redirect_to([:master,@merchant_account])
    else
      render :action => "new" 
    end
  end

  # PUT /merchant_accounts/1
  # PUT /merchant_accounts/1.xml
  def update
    @merchant_account = MerchantAccount.find(params[:id])
    if @merchant_account.update_attributes(params[:merchant_account])
      flash[:notice] = 'MerchantAccount was successfully updated.'
      redirect_to([:master,@merchant_account]) 
    else
      render :action => "edit" 
    end
  end

  # DELETE /merchant_accounts/1
  # DELETE /merchant_accounts/1.xml
  def destroy
    @merchant_account = MerchantAccount.find(params[:id])
    @merchant_account.destroy
    redirect_to(master_merchant_accounts_url) 
  end
end
