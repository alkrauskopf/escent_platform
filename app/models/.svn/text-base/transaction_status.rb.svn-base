class TransactionStatus < ActiveRecord::Base
  has_many :payments
  TransactionStatusNames = ["accepted", "pending", "chargeback", "rejected", "cancelled"]
  
  def self.append_conditions(conditions, options)
    if options[:transaction_status_ids] || options[:transaction_statuses]
      conditions[0] << " AND transaction_status_id IN (?)"
      conditions << (options[:transaction_statuses] ? options[:transaction_statuses] : options[:transaction_status_ids])
    end
    conditions
  end
  
  def self.prepare_regexps
    transaction_status_names = TransactionStatusNames.join('|')
    return Regexp.new("(#{transaction_status_names})\\?"), Regexp.new("(#{transaction_status_names})")
  end
  
  def respond_to?(method)
    method_name = method.to_s
    comparison_re, get_re = self.class.prepare_regexps
    if method_name.match(comparison_re)
      true
    else
      super
    end
  end
  
  def method_missing(method, *args)
    method_name = method.to_s
    comparison_re, get_re = self.class.prepare_regexps
    if (match_data = method_name.match(comparison_re))
      transaction_status = self.class.find_by_name(match_data[1].titleize) rescue nil
      transaction_status == self
    else
      super
    end
  end
  
  def self.respond_to?(method)
    method_name = method.to_s
    comparison_re, get_re = self.prepare_regexps
    if method_name.match(get_re)
      true
    else
      super
    end
  end
  
  def self.method_missing(method, *args)
    method_name = method.to_s
    comparison_re, get_re = self.prepare_regexps
    if (match_data = method_name.match(get_re))
      self.find_by_name(match_data[1].titleize) rescue nil
    else
      super
    end
  end
end

