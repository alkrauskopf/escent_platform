class Payment < ActiveRecord::Base
  attr_accessor :first_name, :last_name
  belongs_to :organization
  belongs_to :merchant_account
  belongs_to :transaction_status
  belongs_to :fundraising_campaign
  belongs_to :user

  validates_presence_of :organization_id
  validates_presence_of :card_number

  def process(options={})
    @credit_card = ActiveMerchant::Billing::CreditCard.new(options[:credit_card].to_hash)

    ActiveMerchant::Billing::CreditCard.require_verification_value = false
    gateway = self.merchant_account.gateway_for_organization(self.organization)
    address = {
      :address1 => self.billing_address,
      :city => self.billing_city,
      :state => self.billing_state_province,
      :zip => self.billing_postal_code,
      :country => self.billing_country,
      :phone => self.billing_phone,
    }
    gateway_options = {:order_id => self.id, :email => options[:email_address], :address => address}
    
    response = gateway.purchase(self.amount.to_i*100, @credit_card, gateway_options)
    
    self.authorization_code = response.authorization.blank? ? self.id.to_s : response.authorization
    if (match_data = self.authorization_code.match(/^\d+;(\d+);/))
      self.authorization_code = match_data[1]
    end
    self.response_message = response.message
    self.card_holder_name = @credit_card.name
    self.card_number = @credit_card.display_number

    if response.success? 
      self.transaction_status = TransactionStatus.accepted
    else
      self.transaction_status_id = TransactionStatus.rejected
    end 
    self.save
    self.errors.add(response.message) unless response.success?
    response.success?
  end
end
