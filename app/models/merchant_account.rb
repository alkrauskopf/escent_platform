class MerchantAccount < ActiveRecord::Base
  has_many :payments
#  has_many :fundraising_campaigns
  
  belongs_to :organization
  
  validates_presence_of :name, :gateway_type
  
  CardTypes = [['Visa', 'visa'], 
  ['MasterCard', 'master'], 
  ['American Express','american_express'], 
  ['Discover', 'discover'], 
  ['Diners Club', 'diners_club'],
  ['Maestro', 'maestro'],
  ['JCB', 'jcb']]
  
  CardTypesHash = CardTypes.inject({}){|lut, t| lut[t[1]]=t[0];lut}
  
  GatewayTypes = [{:name => 'Authorize.Net', :type => 'AuthorizeNet', :supports_refund => true, :refund_requires_card_number => true, :payment_requires_country => false}, 
    {:name => 'CardStream', :type => 'CardStream', :supports_refund => false},
    {:name => 'CyberSource', :type => 'CyberSource', :supports_refund => true, :refund_requires_card_number => false, :payment_requires_country => true},
    {:name => 'Internet Secure', :type => 'InternetSecure', :supports_refund => true, :refund_requires_card_number => true, :payment_requires_country => false},
    {:name => 'Linkpoint', :type => 'Linkpoint', :supports_refund => true, :refund_requires_card_number => false, :payment_requires_country => false},
    {:name => 'Moneris', :type => 'Moneris', :supports_refund => true, :refund_requires_card_number => false, :payment_requires_country => true},
    {:name => 'Payflow', :type => 'Payflow', :supports_refund => true, :refund_requires_card_number => false, :payment_requires_country => true},
    {:name => 'Sage', :type => 'Sage', :supports_refund => true, :refund_requires_card_number => false, :payment_requires_country => false},
    {:name => 'SkipJack', :type => 'SkipJack', :supports_refund => true, :refund_requires_card_number => false, :payment_requires_country => false},
    {:name => 'TransFirst', :type => 'TransFirst', :supports_refund => false, :payment_requires_country => false},
    {:name => 'TrustCommerce', :type => 'TrustCommerce', :supports_refund => true, :refund_requires_card_number => false, :payment_requires_country => false},
    {:name => 'USAEpay', :type => 'USAEpay', :supports_refund => false, :refund_requires_card_number => false, :payment_requires_country => false}]
  
   def gateway_for_organization(organization, options = {})
    options = {:test => true}.merge(options)
    case self.gateway_type.downcase
      when 'authorizenet'
        ActiveMerchant::Billing::AuthorizeNetGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password
      
      when 'internetsecure'
        ActiveMerchant::Billing::InternetSecureGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password
      
      when 'payflow'
        ActiveMerchant::Billing::PayflowGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password, :certification_id => self.gateway_certification_id, :partner => self.gateway_partner
      
      when 'cybersource'
        ActiveMerchant::Billing::CyberSourceGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password, :ignore_avs => self.gateway_ignore_avs, :ignore_cvv => self.gateway_ignore_cvv
      
      when 'sage'
        ActiveMerchant::Billing::SageGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password
       
      when 'linkpoint'
        ActiveMerchant::Billing::LinkpointGateway.new :test => options[:test], :login => self.gateway_login, :pem => self.gateway_pem
      
      when 'transfirst'
        ActiveMerchant::Billing::TransFirstGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password
      
      when 'trustcommerce'
        ActiveMerchant::Billing::TrustCommerceGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password
      
      when 'cardstream'
        ActiveMerchant::Billing::CardStreamGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password
      
      when 'moneris'
        ActiveMerchant::Billing::MonerisGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password
      
      when 'usaepay'
        ActiveMerchant::Billing::UsaEpayGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password
        
#      when 'paypalexpress'
#        ActiveMerchant::Billing::PaypalExpressGateway.new :test => options[:test], :login => self.gateway_login, :password => self.gateway_password, :pem => self.gateway_pem
      
    end
  end
end
