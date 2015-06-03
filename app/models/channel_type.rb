class ChannelType < ActiveRecord::Base
  
  def self.normal
    @normal ||= self.find_by_name("Normal")
  end
end
