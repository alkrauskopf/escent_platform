class ContentObjectTypeGroup < ActiveRecord::Base

  named_scope :images, :conditions => { :name => "IMAGE" }


end
