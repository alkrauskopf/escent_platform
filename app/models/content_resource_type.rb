class ContentResourceType < ActiveRecord::Base
 include PublicPersona

 has_many :contents

 has_many :coop_app_content_resource_types, :dependent => :destroy
 has_many :coop_apps, :through => :coop_app_content_resource_types
  
 validates_presence_of :name

 scope :ctl, :conditions => ["name = ?","Time & Learning"]

  
  def self.auto_complete_on(query)
    ContentResourceType.where('name LIKE ?', '%' + query + '%').order('name')
  end

end
