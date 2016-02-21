class ContentUploadSource < ActiveRecord::Base
  has_many :contents

  scope :ctl,  :conditions => ["name = ? ", "CTL"]

end
