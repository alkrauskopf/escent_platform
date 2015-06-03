class Admin::DonationsController < Admin::ApplicationController
  
  def index
    @payments = @current_organization.payments
  end
  
  def show
    @payment = @current_organization.payment.find(params[:id])
  end
  
end