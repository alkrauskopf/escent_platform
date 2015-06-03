class FundraisingCampaign < ActiveRecord::Base
  belongs_to :organization
  belongs_to :merchant_account
  has_many :payments
  
  named_scope :active,  :conditions => ["starts_at <= ? AND (ends_at IS NULL OR ends_at > ?)", Time.now, Time.now], :order => "name"
  named_scope :pending, :conditions => ["(starts_at > ? OR starts_at IS NULL)", Time.now], :order => "name"
  named_scope :closed,  :conditions => ["ends_at <= ?", Time.now], :order => "name"
  
  def show_date_range
    "#{self.starts_at ? self.starts_at.to_date.to_s(:short) : 'no start date'} - #{self.ends_at ? self.ends_at.to_date.to_s(:short) : 'no end date'}"
  end
  
  def can_be_deleted?
    self.payments.empty?
  end
end
