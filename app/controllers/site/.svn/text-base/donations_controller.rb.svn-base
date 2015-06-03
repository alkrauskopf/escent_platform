class Site::DonationsController < Site::ApplicationController
  layout "site"    
  
  protect_from_forgery :except => [:add_reply, :report_abuse]
  before_filter :find_featured_topic, :only => [:show, :add_comment]
  
  def show

  end   
  
  def give
    @payment = Payment.new
  end
  
  def create
    @payment = Payment.new(params[:payment])
    @payment.organization = @current_organization    
    @payment.merchant_account = @current_organization.merchant_account
    @payment.user = @current_user
    
    credit_card = CreditCard.new(params[:credit_card].merge({:first_name => @payment.first_name, :last_name => @payment.last_name, :type => @payment.card_type, :number => @payment.card_number}))
    
    options = {:credit_card => credit_card}
    if @payment.save && @payment.process(options)    
      redirect_to :action => :show
    else
      render :action => "give"     
    end 
  end
end
