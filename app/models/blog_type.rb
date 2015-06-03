class BlogType < ActiveRecord::Base

  include PublicPersona
  
  has_many :blogs
  
  named_scope :pov, :conditions => ["blog_type = ?", "POV"]
  named_scope :bio, :conditions => ["blog_type = ?", "UB"]
  named_scope :org, :conditions => ["blog_type = ?", "OD"]  
  named_scope :asset, :conditions => ["blog_type = ?", "OT"]
  named_scope :testimonial, :conditions => ["blog_type = ?", "TST"] 
  named_scope :instruction, :conditions => ["blog_type = ?", "INST"]     
  named_scope :project, :conditions => ["blog_type = ?", "PROJ"]
  named_scope :pov_header, :conditions => ["blog_type = ?", "POV_H"]
  named_scope :our_offering, :conditions => ["blog_type = ?", "OFR"]
  named_scope :about_us, :conditions => ["blog_type = ?", "AU"]
  named_scope :all_by_position, :order => "position"
  named_scope :for_app, :conditions => ["blog_type = ?", "APP"]  

  named_scope :of_type, lambda{|typ| {:conditions => ["blog_type = ? ", typ.upcase]}}


  def app_type?
    self.blog_type == "APP"
  end

end
