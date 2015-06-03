class ItlOrgOption < ActiveRecord::Base
  include PublicPersona

  belongs_to :organization
  belongs_to :classroom_period

  has_many :itl_org_option_app_methods, :dependent => :destroy
  has_many :app_methods, :through => :itl_org_option_app_methods

  has_many :itl_org_option_filters, :dependent => :destroy
  has_many :tl_activity_type_tasks, :through => :itl_org_option_filters
     
  validates_numericality_of :stat_window, :greater_than_or_equal_to => 0
  validates_format_of :schedule_url, :with => /^((http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?)*$/, 
  :message => 'not valid, URL format', :allow_blank => true
   

end
