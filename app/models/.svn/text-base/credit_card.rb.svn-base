class CreditCard
  attr_accessor :name, :month, :year, :type, :number 
  def initialize(options={})  
    @name = options[:name]
    @month = options[:month]
    @year = options[:year]
    @number = options[:number]
    @first_name = options[:first_name]
    @last_name = options[:last_name]
  end
 
  def to_hash
    {:first_name => @first_name, :last_name =>@last_name,:month => @month , :year => @year,  :number => @number}
  end 
end