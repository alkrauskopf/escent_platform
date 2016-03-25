class Blog < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :organization
  belongs_to   :act_subject
  belongs_to   :blog_type
  belongs_to   :coop_app
    
  has_many :blog_users, :dependent => :destroy
  has_many :users, :through => :blog_users
  has_many :panelists, :through => :blog_users, :source=> :user
  has_many :blog_posts, :dependent => :destroy
  has_one   :total_view, :as => :entity, :dependent => :destroy
  has_one   :total_share, :as => :entity, :dependent => :destroy
    
  scope :features, :conditions => ["feature = ?", true]
  scope :featured, :conditions => ["feature = ?", true]
  scope :active, :conditions =>["active = ?", true], :order => "position"
  scope :not_featured, :conditions => ["feature = ?", false], :order => "position"
  scope :by_type_position, :order => "blog_type_id, position"
  scope :for_type, lambda{|blog| {:conditions => ["blog_type_id = ? ", blog.blog_type_id]}}
  scope :of_type, lambda{|blog_type| {:conditions => ["blog_type_id = ? ", blog_type.id]}}
  scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}
  scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id]}}
    
  validates_presence_of :title

#  has_attached_file :picture, :styles => { :normal => "420x" }, :default_style => :normal
  has_attached_file :picture,
                    :path => ":rails_root/public/blog_images/:id/:basename.:extension",
                    :url => "/blog_images/:id/:basename.:extension"
  
     
  def app_blog?
    self.coop_id rescue nil
  end
     
  def blog_post_count
    self.blog_posts.size
  end

  def active?
    self.active
  end

  def increment_shares
    self.total_share ||= TotalShare.create(:entity => self)
    self.total_share.increment
  end
  
  def shares
    self.total_share ||= TotalShare.create(:entity => self)
    self.total_share.shares
  end
   
  def increment_views
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.increment
  end
  
  def views
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.views
  end
  
  def reset_views
    if self.total_view
      self.total_view.destroy
    end
  end

  def can_be_delete?
    self.blog_posts.blank?
  end

  def clear_feature
    self.update_attributes(:feature => false)
  end

  def set_as_feature
    self.organization.blogs.each do |blog|
      if blog.blog_type_id == self.blog_type_id
        blog.clear_feature
      end
    end
    self.update_attributes(:feature => true, :active => true)
  end

  def sequence_posts
  posts = self.blog_posts.by_position
  posts.each_with_index do |post,idx|
    post.update_attributes(:position=>idx+1)
    end
  end

  def verify_still_active
    unless self.blog_post.active.size >0
          self.update_attributes( :feature => false, :active => false)
    end
  end

  def featured_post
    self.blog_posts.featured.first rescue nil
  end
  
  def set_as_active
      self.update_attribute("active", true)
  end

  def set_as_inactive
    self.update_attributes(:active => false, :feature => false)
  end  
  
  # def before_save
  #    active = false if active.blank?
  #  end
  def panel_name_list
     self.panelists.collect{|p| p.full_name}.join(", ")
  end

  def panelists_with_active_posts
   self.panelists.select{|p| !self.blog_posts.for_panelist(p).active.empty?} 
  end

  def panel_list_with_posts
   self.panelists_with_active_posts.collect{|p| p.full_name}.join(", ")
  end
  
  def creator
     User(self.creator_id) rescue nil
  end  
  
end
