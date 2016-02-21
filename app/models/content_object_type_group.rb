class ContentObjectTypeGroup < ActiveRecord::Base

  scope :images, :conditions => { :name => "IMAGE" }


end
