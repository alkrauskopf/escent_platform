class Content < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :organization
  belongs_to :child_content,:class_name => "Content"
  belongs_to :content_status
  belongs_to :user
  belongs_to :content_object_type
  belongs_to :content_upload_source
  belongs_to :act_subject
  belongs_to :subject_area
  belongs_to :content_resource_type
  belongs_to :updater, :class_name => 'User', :foreign_key => "updated_by"
    
  has_one   :total_view, :as => :entity, :dependent => :destroy
  has_one   :star_rating, :as => :entity, :dependent => :destroy
  has_one   :itl_blackbelt, :dependent => :destroy
  has_one   :elt_case_evidence
  
  has_many :discussions, :as => :discussionable, :order => "last_posted_at desc", :dependent => :destroy  
  has_many :reported_abuses, :class_name => "ReportedAbuse", :as => :entity, :dependent => :destroy
  has_many :topic_contents, :dependent => :destroy
  has_many :topics, :through => :topic_contents
  has_many :folders, :through => :topic_contents
  has_many :classroom_contents, :dependent => :destroy
  has_many :classrooms, :through => :classroom_contents, :order => "position"
  has_many :authorizations, :as => :scope, :dependent => :destroy
  has_many :act_standard_contents, :dependent => :destroy
  has_many :act_standards, :through => :act_standard_contents, :order => "position"  
  has_many :act_score_range_contents, :dependent => :destroy
  has_many :act_score_ranges, :through => :act_score_range_contents
  has_many :act_questions  

  has_many :tlt_sessions
  has_many :dle_resources, :dependent => :destroy 
  has_many :coop_app_resources, :dependent => :destroy  

  
  validates_presence_of :title
  validates_presence_of :content_object_type_id, :message => "- Invalid File Extension or File Name, No Periods in File Name."
 #
 # ALK Addition
  validates_presence_of :subject_area_id, :message => "- Invalid Subject Area"
  validates_presence_of :content_resource_type_id, :message => "- Invalid Resource Type"
  
  validates_acceptance_of :terms_of_service, :message => "You must declare you are authorized to submit resource.", :allow_nil => false, :accept => true, :if => :terms_of_service_required?
  attr_accessor :except_terms_or_service_vaild

  validates_format_of :source_url, :with => /^((http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?)*$/,
                      :message => 'not valid, format http://www.escentpartners.com', :allow_nil => true

  has_attached_file :source_file,
                    :path => ":rails_root/public/resourcelibrary/:id/:style/:basename.:extension",
                    :url => "/resourcelibrary/:id/:style/:basename.:extension"

  has_attached_file :source_file_preview,
                    :path => ":rails_root/public/resourcelibrary/:id/:style/:basename.:extension",
                    :url => "/resourcelibrary/:id/:style/:basename.:extension" ,
                    :styles => {:thumb => "41x41>", :med_thumb => "90x90>"}

  scope :active, :conditions => { :is_delete => false}
  scope :deleted, :conditions => { :is_delete => true }
  scope :trash, :conditions => { :is_delete => true }
  scope :available, {:include => :content_status, :conditions =>  ["content_statuses.name = ?", "Available"]}
  scope :available_and_restricted, {:include => :content_status, :conditions =>  ["content_statuses.name = ? OR content_statuses.name = ?", "Available", "Restricted"]}
  scope :confidential, {:include => :content_status, :conditions =>  ["content_statuses.name = ?", "Confidential"]}
  scope :embed_code, {:include => :content_object_type, :conditions =>  "content_object_types.content_object_type_group_id" == 4 }
  scope :for_ctl, :conditions =>  ["subject_area_id = ?", 7]
  scope :for_subject, lambda{|subject| {:conditions => ["subject_area_id = ? ", subject.id], :order => "created_at DESC"}}
  scope :for_user, lambda{|user| {:conditions => ["user_id = ? ", user.id], :order => "updated_at DESC"}}
  scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id], :order => "updated_at DESC"}}
  scope :for_type, lambda{|type| {:conditions => ["content_resource_type_id = ? ", type.id], :order => "updated_at DESC"}}
  scope :for_type_name, lambda{|name| {:include => :content_resource_type, :conditions => ["content_resource_types.name = ?", name], :order => "updated_at DESC"}}
  scope :with_authorization, lambda{|user,auth| {:include => "authorizations", :conditions => ['authorizations.user_id = ? AND authorizations.scope_type = ? AND authorizations.authorization_level_id = ?', user.id, 'Content', auth.id], :order => 'title'}}

  scope :with_keywords_and_type, lambda { |keywords, type, options|
    condition_strings = []
    conditions = []
    
    keywords.parse_keywords.each do |keyword|
      case type
      when "religious_affiliation"
        condition_strings << '(religious_affiliations.name LIKE ?)'
        conditions << "%#{keyword}%"
      when "type"
        condition_strings << '(content_object_types.name REGEXP ?)'
        conditions << "^#{keyword}"
      when "organization_name"
        condition_strings << '(organizations.name REGEXP ? OR organizations.name REGEXP ?)'
         conditions << "^#{keyword}"
         conditions << "\s+#{keyword}"
      else
#
#  ALK Expand Keyword Search to include caption and subject_are and resource_type
# 
        
        condition_strings << '(title REGEXP ? OR title REGEXP ? OR caption REGEXP ? OR caption REGEXP ? OR subject_areas.name REGEXP ? OR content_resource_types.name REGEXP ? OR content_resource_types.name REGEXP ?)'
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}"         
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}"  
        conditions << "^#{keyword}"
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}"  
      end
    end
    condition_string = condition_strings.join(" OR ")
    conditions.unshift condition_string
    order_by = (options[:order] || "title")
    {:conditions => conditions, :include => [{:organization => :religious_affiliation}, :subject_area, :content_resource_type, :user, {:content_object_type => :content_object_type_group}], :order => order_by}
  }

  scope :with_keywords, lambda { |keywords, options|
    condition_strings = []
    conditions = []
#
#  ALK Expand Keyword Search to include caption and subject_area and resource_type
#  
    keywords.parse_keywords.each do |keyword| 
        condition_strings << '(title REGEXP ? OR title REGEXP ? OR caption REGEXP ? OR caption REGEXP ? OR subject_areas.name REGEXP ? OR content_resource_types.name REGEXP ? OR content_resource_types.name REGEXP ?)'
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}"         
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}"  
        conditions << "^#{keyword}"
        conditions << "^#{keyword}"
        conditions << "\s+#{keyword}"  
    end
    condition_string = condition_strings.join(" OR ")
    
    unless options[:organization].organization_relationships.find_all_by_relationship_type('content_partner').empty?
      condition_string = "(#{condition_string}) AND (organization_id IN (?))"
      
      unless conditions.empty?
        conditions.unshift condition_string      
        conditions.push( options[:organization].content_partners.collect{|o| o.id} << options[:organization].id )
      end
    else
      conditions.unshift condition_string
    end
    order_by = (options[:order] || "title")
#
#ALK Include Submitter Info
#
    {:conditions => conditions, :include => [:organization, :subject_area, :content_resource_type, :user, {:content_object_type => :content_object_type_group}], :order => order_by}
  }
  
  
    scope :with_subjects, lambda { |keywords, options|
    condition_strings = []
    conditions = []
 
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(subject_areas.name LIKE ?)'
      conditions << "%#{keyword}%"
    end
    condition_string = condition_strings.join(" OR ")
    conditions.unshift condition_string

    order_by = (options[:order] || "title")
    {:conditions => conditions, :include => [:organization, :subject_area, :user, {:content_object_type => :content_object_type_group}], :order => order_by}
  }
  
  
  
  scope :with_organizations, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(organizations.name LIKE ?)'
      conditions << "%#{keyword}%"
    end
    condition_string = condition_strings.join(" OR ")
    unless options[:organization].organization_relationships.find_all_by_relationship_type('content_partner').empty?
      condition_string = "(#{condition_string}) AND (organization_id IN (?))"
      conditions.unshift condition_string
      conditions.push( options[:organization].content_partners.collect{|o| o.id} << options[:organization].id )
    else
      conditions.unshift condition_string
    end
    order_by = (options[:order] || "title")
    {:conditions => conditions, :include => [:organization, {:content_object_type => :content_object_type_group}], :order => order_by}
  }
  
  scope :with_content_upload_source, lambda { |source_id| { :conditions => { :content_upload_source_id => source_id } } }

  after_initialize :after_initialize_method
  def after_initialize_method
    unless self.publish_start_date
      self.publish_start_date = Time.now
    end
    unless self.publish_end_date
      self.publish_end_date = self.publish_start_date.advance(:years => 10)
    end
    if self.publish_start_date == self.publish_end_date
      self.publish_end_date = self.publish_start_date.advance(:years => 10)
    end
    unless self.content_status
      self.content_status_id = 1
    end
  end

  def self.available_to_user(user)
    if user.nil?
      items = Content.active.available      
    elsif user.content_manager?
      items = Content.active.available_and_restricted
      if user.superuser?
       items += Content.active.confidential
      else
        user.content_manager_orgs.each do |org|
          items += org.contents.active.confidential
        end
      end
    else
      items = Content.active.available
    end
    items.sort_by{|c| c.title}
  end

  def self.available_to_user_organization(user, keys, org, order_by)
    if user.nil?
      items = Content.active.available.with_organizations keys, :organization => org, :order => order_by   
    elsif user.content_manager?
      items = Content.active.available_and_restricted.with_organizations keys, :organization => org, :order => order_by
      if user.superuser?
       items += Content.active.confidential.with_organizations keys, :organization => org, :order => order_by
      else
       confidentials = Content.active.confidential.with_organizations keys, :organization => org, :order => order_by
       user.content_manager_orgs.each do |org|
          items += confidentials.compact.select{|c| c.organization_id == org.id}
        end
      end
    else
      items = Content.active.available.with_organizations keys, :organization => org, :order => order_by 
    end
    items.sort_by{|c| c.title}
  end

  def self.available_to_user_subject(user, keys, org, order_by)
    if user.nil?
      items = Content.active.available.with_subjects keys, :organization => org, :order => order_by   
    elsif user.content_manager?
      items = Content.active.available_and_restricted.with_subjects keys, :organization => org, :order => order_by
      if user.superuser?
       items += Content.active.confidential.with_subjects keys, :organization => org, :order => order_by
      else
       confidentials = Content.active.confidential.with_subjects keys, :organization => org, :order => order_by
       user.content_manager_orgs.each do |org|
          items += confidentials.compact.select{|c| c.organization_id == org.id}
        end
      end
    else
      items = Content.active.available.with_subjects keys, :organization => org, :order => order_by 
    end
    items.sort_by{|c| c.title}
  end
  
  def self.available_to_user_with_keywords(user, keys, org, order_by)
    if user.nil?
      items = Content.active.available.with_keywords keys, :organization => org, :order => order_by   
    elsif user.content_manager?
      items = Content.active.available_and_restricted.with_keywords keys, :organization => org, :order => order_by
      if user.superuser?
       items += Content.active.confidential.with_keywords keys, :organization => org, :order => order_by
      else
       confidentials = Content.active.confidential.with_keywords keys, :organization => org, :order => order_by
       user.content_manager_orgs.each do |org|
          items += confidentials.compact.select{|c| c.organization_id == org.id}
        end
      end
    else
      items = Content.active.available.with_keywords keys, :organization => org, :order => order_by 
    end
    items.sort_by{|c| c.title}
  end

  
  def expired?
    (self.publish_start_date > Date.today || self.publish_end_date < Date.today)
  end
  
  def active?
    (!self.deleted? && !self.expired? && !self.pending?)
  end

  def available?
    self.content_status.name == "Available"
  end

  def restricted?
    self.content_status.name == "Restricted"
  end

  def confidential?
    self.content_status.name == "Confidential"
  end

  def deleted?
    self.is_delete || self.content_status.name == "Deleted"
  end

  def pending?
    self.content_status.name == "Pending"
  end

  def disposition
    disposition = self.content_status.name
    if self.expired?
      disposition = "Expired"
    else
      disposition = self.deleted? ? "Unavailable" : disposition
    end
    disposition 
  end
   
  def act_subject?
    !self.act_subject_id.nil? && !(self.act_subject_id == 99) && self.act_subject
  end
   
  def editable_by_user?(user)
    edit = false
    unless user.nil? || !self.organization
      edit = user.content_manager_for_org?(self.organization) || (self.user && (user==self.user))
    end
    edit
  end
  
  def viewable_by_user?(user)
    view = false
    if !self.deleted?
      if user.nil?
        view = self.available?
      else
        if user.superuser? || (self.user && (self.user == user)) || (self.organization && user.content_manager_for_org?(self.organization))
        view = true
        elsif !self.active?
          view = false
        else
          view = self.available?
          if self.restricted?
              view = user.content_manager?
          elsif self.confidential?
              view =  (user.organization_id == self.organization_id)
          end
        end
      end
    end
    view
  end

  def viewable_by_classroom_user?(user, classroom)
    view = false
    unless user.nil?
      view = self.active?
      unless !self.active?
        if user.nil?
          view = self.available?
        else
          if self.available?
            view = true
          elsif self.restricted?
            view = user.content_manager? || user.superuser?
          elsif self.confidential?
            view = self.organization ? (user.content_manager_for_org?(self.organization) || user.superuser? || user.in_classroom?(classroom)) : false
          else
            view = false
          end
        end
      end
    else
      view = self.available?
    end
    view
  end

  def usable_by_org?(org)
    if self.organization && self.active?
      if self.available? || self.restricted?
        view = true
      end
      if self.restricted?
        view = (self.organization == org) ? true : false
      end
    else
      view = false
    end
    view
  end
  
  def parent_subject
    unless self.subject_area.parent_id.nil?
      self.subject_area.parent
    else
      self.subject_area
    end
  end

  def irr_resource?
    self.itl_blackbelt && self.itl_blackbelt.tlt_session
  end

  def app_resource_position(org, app)
    coop_app = self.coop_app_resources.for_org(org).for_app(app).first rescue nil
    coop_app ? coop_app.position : 0
  end
 
  def position_for_topic(topic)
    self.topic_contents.select{|tc| tc.topic_id == topic.id}.first.position rescue ""
  end
  
  def position_for_classroom(entity, folder)
    if entity.class.to_s == "Classroom"
      self.classroom_contents.select{|cc| cc.classroom_id == entity.id}.first.position rescue ""
    else
      folder.nil? ? (self.topic_contents.unfoldered.select{|cc| cc.topic_id == entity.id}.first.position rescue "") : (self.topic_contents.for_folder(folder).select{|cc| cc.topic_id == entity.id}.first.position rescue "") 
    end     
  end  
  
  def increment_views
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.increment
  end
  
  def views
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.views
  end

  def add_star_rating(rating)
    self.star_rating ||= StarRating.create(:entity => self)
    self.star_rating.add rating
  end
  
  def set_as_pending
    self.update_attribute(:pending, true)
  end
  
  def pending?
    self.pending
  end

  def embed_code?
    self.content_object_type.content_object_type_group.name == "EMBED CODE"
  end 
  
  def favorite_of
#     content_auths = Authorization.find(:all, :conditions => ["scope_type = ? AND authorization_level_id = ? AND scope_id = ?", "Content", AuthorizationLevel.favorite, self])
     content_auths = Authorization.where('scope_type = ? AND authorization_level_id = ? AND scope_id = ?', 'Content', AuthorizationLevel.favorite, self)
     # followers = []
     # content_auths.each do |ca|
     # followers << User.find(:first, :conditions => ["id= ?", ca.user_id])
    # end
    content_auths.map{|ca| ca.user}.compact.uniq
  end     

  def leaders_using
     @clsrms = self.classrooms
     self.topics.active.each do |tpc|
       @clsrms << tpc.classroom
     end
  
  leaders = []
  @clsrms.each do |c|
    leaders << c.leaders
    end
  leaders.uniq
  end 


  def set_content_upload_source(source_name)
    source = ContentUploadSource.find_by_name(source_name)
    self.update_attribute(:content_upload_source_id, source.id)
  end
  
  def make_as_delete
    self.update_attribute(:is_delete, true)
  end
  
   def terms_of_service_required?
    !self.terms_of_service
  end
  
  def add_comment(options={})
    timestamp = Time.now
    discussion = self.discussions.create(
      :parent => options[:parent_id] ? self.discussions.find_by_public_id(options[:parent_id]) : nil,
      :organization => self.organization,
      :comment => options[:comment],
      :user => options[:user])
    discussion.update_last_posted_at timestamp
  end  
  
  def valid_formats
    format_groups = ContentObjectType.all.group_by(&:content_object_type_group_id)
    format_string = "<center><strong><u>VALID FILE TYPES</u></strong></center><br/>"
    format_groups.each do |gi,formats|
    group_name = ContentObjectTypeGroup.find(gi).name
    unless group_name == "LINK" || formats.size == 0
        format_string << "<u>" + group_name.upcase + "</u><br/>"
        formats.each_with_index do |f, idx|
          format_string << "." + f.content_object_type + "&nbsp;&nbsp;"
            format_string << "<br/>" if (idx+1)%4 == 0 
        end
        format_string << "<br/><br/>"
      end
    end
    format_string
  end
end
