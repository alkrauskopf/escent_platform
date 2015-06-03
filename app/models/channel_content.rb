class ChannelContent < ActiveRecord::Base
  belongs_to :content
  belongs_to :channel
  
  acts_as_list :scope => :channel
end
