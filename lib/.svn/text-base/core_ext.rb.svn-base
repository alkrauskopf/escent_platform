module Base64
  module_function # this seems to be necessary -- get a "wrong number of arguments (2 for 1)" without it this line.
  
  def encode64(bin,options={})
    if (options[:no_line_break] == true)
      [bin].pack("m").gsub(/\n/, '') 
    else
      [bin].pack("m")
    end   
  end
end

class Hash
  def rempty?
    self.empty? ? true : self.inject(true){|result, pair| result && (pair[1].is_a?(Hash) ? pair[1].rempty? : false)}
  end
end

class Object
  #recursive send
  def rsend(msg, *args)
    if msg.to_s.include? '.'
      msg.to_s.split('.').inject(self){ |obj, m| obj.send(m) }
    else
      send(msg, *args)
    end
  end
end

class String
  def is_numeric?
    self =~ /(^-?\d\d*\.\d*$)|(^-?\d\d*$)|(^-?\.\d\d*$)/
  end
  
  def parse_keywords
    self.split(/"(.+?)"|\s+/).reject{|s| s.empty? || s == "\""}
  end
end

class Numeric
  def is_numeric?
    true
  end
end


class Symbol
  def is_numeric?
    self.to_s.is_numeric?
  end
end

class DateTime
  def is_numeric?
    false
  end
end

class NilClass
  def is_numeric?
    false
  end
  def to_d
    0.to_d
  end
end

class BigDecimal
  def to_d
    self
  end
end

class Hash
  def to_url(omit_q_mark=false)
    q = self.to_query.to_query('')
    if omit_q_mark
      q[0..0] = ""
    else
      q[0..0] = "%3F"
    end
    q
  end
end

class Time
  # Acts the same as #strftime, but returns a localized version of the
  # formatted date/time string.
  def l(format=:default)
    format = ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[format] if format.is_a?(Symbol)
    format ? localize(format) : to_default_s
  end
  
  def is_numeric?
    true
  end
  def to_d # created for lib/sort_helper.rb
    self.to_f
  end
end

class Date
  # Acts the same as #strftime, but returns a localized version of the
  # formatted date/time string.
  def l(format=:default)
    format = ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[format] if format.is_a?(Symbol)
    format ? localize(format) : to_default_s
  end
end

#module ActiveMerchant
#  module Billing
#    class CreditCard
#      def display_type
#        MerchantAccount::CardTypes.find {|t| t[1] == self.type}.first
#      end
#    end
#  end
#end

class << ActiveRecord::Base 
  public :sanitize_sql 
end