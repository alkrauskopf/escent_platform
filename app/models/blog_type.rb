class BlogType < ActiveRecord::Base

  include PublicPersona
  
  has_many :blogs
  
  scope :pov, :conditions => ["blog_type = ?", "POV"]
  scope :bio, :conditions => ["blog_type = ?", "UB"]
  scope :org, :conditions => ["blog_type = ?", "OD"]
  scope :asset, :conditions => ["blog_type = ?", "OT"]
  scope :testimonial, :conditions => ["blog_type = ?", "TST"]
  scope :instruction, :conditions => ["blog_type = ?", "INST"]
  scope :project, :conditions => ["blog_type = ?", "PROJ"]
  scope :pov_header, :conditions => ["blog_type = ?", "POV_H"]
  scope :our_offering, :conditions => ["blog_type = ?", "OFR"]
  scope :about_us, :conditions => ["blog_type = ?", "AU"]
  scope :all_by_position, :order => "position"
  scope :for_app, :conditions => ["blog_type = ?", "APP"]

  scope :of_type, lambda{|typ| {:conditions => ["blog_type = ? ", typ.upcase]}}


  def app_type?
    self.blog_type == "APP"
  end

  def self.by_position
    order('position ASC')
  end

end
