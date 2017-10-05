class Topic < ActiveRecord::Base
  include PublicPersona

  belongs_to :organization
  belongs_to :user
  belongs_to :classroom
  belongs_to :classroom_referral

  
  has_many :discussions, :as => :discussionable, :order => "last_posted_at desc", :dependent => :destroy
  has_many :setting_values, :as => :scope, :dependent => :destroy
  has_many :topic_contents, :dependent => :destroy
  has_many :contents, :through => :topic_contents, :order => "position"
  has_many :folder_positions, :as=>:scope, :dependent => :destroy, :order => "pos"
  has_many :positioned_folders,:through => :folder_positions, :source => :folder, :uniq=>true
  has_many :folders, :through => :topic_contents, :uniq=>true
  has_many :classroom_referrals, :dependent => :destroy
  has_many :act_standard_topics, :dependent => :destroy
  has_many :act_standards, :through => :act_standard_topics, :order => "position"  
  has_many :act_score_range_topics, :dependent => :destroy
  has_many :act_score_ranges, :through => :act_score_range_topics
  has_many :tlt_sessions  
  has_many :tlt_dashboards
  
  accepts_nested_attributes_for :setting_values

  # scope :active,  :conditions => ["publish_starts_at <= ? AND (publish_ends_at IS NULL OR publish_ends_at > ?)", Time.now, Time.now], :order => "title"
  scope :active, :order => "title"
  scope :pending, :conditions => ["(publish_starts_at > ? OR publish_starts_at IS NULL)", Time.now], :order => "title"
  scope :closed,  :conditions => ["publish_ends_at <= ?", Time.now], :order => "title"
  scope :estimated_active,  :conditions => ["estimated_end_date >= ?", Time.now], :order => "title"
  scope :estimated_closed,  :conditions => ["estimated_end_date <= ?", Time.now], :order => "title"
  scope :searchable, :conditions => {:searchable => true}
  scope :opened,  :conditions => ['is_open = ?', true], :order => 'estimated_start_date'

  validates_presence_of :title
  validates_presence_of :estimated_start_date, :message => "Please Define An Estimated Start & End Date."
  validates_presence_of :estimated_end_date 
  
#  PermissionToContributeOptions = [['Any member of FaithStreams','all']]
#  ModerationOptions = [['Posts appear immediately','None'],['All posts must be approved','Required']]
  #SettingOptions = [{:label => "Who may contribute", :options => PermissionToContributeOptions}, {:label => "Moderation", :options => ModerationOptions}]
#  SettingOptions = [{:label => "Who may contribute", :options => PermissionToContributeOptions}]
  
  scope :with_organizations, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(organizations.name LIKE ?)'
      conditions << "%#{keyword}%"
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "title")    
    {:conditions => conditions, :include => :organization, :order => order_by}
  }
  
  scope :with_titles, lambda { |keywords, options|
    condition_strings = []
    conditions = []
    keywords.parse_keywords.each do |keyword| 
      condition_strings << '(title LIKE ?)'
      conditions << "%#{keyword}%"
    end
    conditions.unshift condition_strings.join(" OR ")
    order_by = (options[:order] || "title")    
    {:conditions => conditions, :include => :organization, :order => order_by}
  }

  def self.open
 #   where('is_open')
  end

  def sequence_resources(folder)
    resources = folder.nil? ? self.topic_contents.unfoldered.sort_by{|tc|tc.position} : self.topic_contents.for_folder(folder).sort_by{|tc|tc.position}
    resources.each_with_index do |rsrc,idx|
    rsrc.update_attributes(:position=>idx+1)
    end
  end

  def sequence_all_resource_folders
    self.folders.each do |folder|
      self.sequence_resources(folder)
    end
    self.sequence_resources(nil)
  end

  def folder_position(folder)
    self.folder_positions.for_folder(folder).empty? ? 0 : self.folder_positions.for_folder(folder).first.pos
  end

  def resource_folders
    self.folder_positions.empty? ? [] : self.folder_positions.sort_by{|fp| fp.pos}.map{|fp| fp.folder}.compact.uniq
  end

  def embed_codes
    self.contents.select{|c| c.embed_code? && c.available? && c.active?}
  end
 
  def update_discussion_setting_value_named(setting_name, value)
    setting_value = self.setting_values.discussion_settings.find_or_create_by_setting_id(DiscussionSetting.find_by_name(setting_name).id) 
    setting_value.update_attributes! :value => value
  end
  
  def discussion_setting_value_named(setting_name)
    setting_value = self.setting_values.discussion_settings.where('settings.name = ?', setting_name).first
    setting_value ? setting_value.value : DiscussionSetting.find_by_name(setting_name).default_value
  end
  
  def can_be_deleted?
    self.discussion_count.zero?
  end
  
  def active?
    Topic.active.include?(self)
  end
  
  def open?
    self.is_open
  end
  
  def featured?
    self.classroom.featured_topic_id == self.id
  end
  
  def notify?
    self.should_notify
  end
    
  def add_comment(options={})
    timestamp = Time.now
    self.update_attributes :last_posted_at => timestamp
    discussion = self.discussions.create(
      :parent => options[:parent_id] ? self.discussions.find_by_public_id(options[:parent_id]) : nil,
      :organization => self.classroom.organization,
      :comment => options[:comment],
      :user => options[:user])
    discussion.update_last_posted_at timestamp
  end
  
  def discussion_count
    self.discussions.active.inject(0){|sum, discussion| sum + 1 + discussion.children.size}
  end
  
  def reported_abuses_count
    self.discussions.active.inject(0){|sum, discussion| sum + discussion.reported_abuses.size}
  end
  
  def discussion_abuses
    discussions = []
    
    self.discussions.active.each do |discussion|
      discussions << discussion unless discussion.reported_abuses.empty?
    end
    discussions
  end  
  
  def discusssion_by_same_author

    #  This is screwed up.  Don't know what it's for

    # discussion_users = self.organization.authorizations.find(:all , :conditions => ["authorization_level_id in (?)" , [5 , 2]]) 
    if false
      discussion_users = self.classroom.organization.authorizations.where('authorization_level_id in (?)' , [5 , 2])
      user_ids = discussion_users.collect(&:user_id) #discussion_moderator and administrator
      Discussion.where('discussionable_id = ? AND discussionable_type = ? AND user_id in (?) AND suspended_at IS NULL', self.id, 'Topic', user_ids).order('created_at DESC').first

      user_ids = (!self.classroom.nil? && !self.classroom.leaders.empty?) ? self.classroom.leaders.collect{|u| u.id} : [] #classroom_leaders
      discussions = []
      unless user_ids.empty?
        discussions = Discussion.all
            # Discussion.all.where('discussionable_id = ? AND discussionable_type = ? AND user_id in (?) AND suspended_at IS NULL', self.id, 'Topic', user_ids).order('created_at DESC').first
      end
    end
    self.discussions
  end

  def active_discussions
    self.discussions.where('suspended_at IS NULL').order('created_at DESC')
  end

  def last_leader_comment
    leader_ids = self.classroom.leaders.collect{|l| l.id}.uniq
    discussions = self.discussions.where('suspended_at IS NULL AND user_id in(?) AND parent_id IS NULL', leader_ids).order('created_at DESC')
    discussions.empty? ? nil : discussions.first
  end

  def self.features
    features = []
    self.where('featured_content is not null').each {|topic| features << topic.featured_content} and return features
  end

  def featured_resource
    Content.find(self.featured_content) rescue nil
  end
  
  def resources_used
   # Content.find(:all, :conditions => ["topic_contents.topic_id = ?", self.id], :include => "topic_contents")
    self.contents
  end
  
  def unfoldered_resources
    self.topic_contents.unfoldered.sort_by{|tc| tc.position}.collect{|tc| tc.content}.flatten.compact.select{|r| r.active? && (r.id != self.featured_content)}
  end
 
  def folders_for_resource(rsrc)
    self.topic_contents.for_resource(rsrc).collect{|tc| tc.folder}.compact
  end
 
  def resources_for_folder(folder)
    folder.nil? ? self.unfoldered_resources : self.topic_contents.for_folder(folder).collect{|tc| tc.content}.select{|c| c.active?}.compact
  end

  def ifa_viewable?
    self.classroom.ifa_classroom_option && self.classroom.organization.ifa_org_option
  end

  def strands
    self.act_standards.sort_by{|s| [s.act_master.abbrev, s.name]}
  end

  def duplicate_contents(lu)
    lu.topic_contents.each do |content|
      dup_content = TopicContent.new
      dup_content = content.dup
      self.topic_contents << dup_content
    end
  end

  def duplicate_ifa(lu)
    lu.act_standard_topics.each do |strand|
      dup_strand = ActStandardTopic.new
      dup_strand = strand.dup
      self.act_standard_topics << dup_strand
    end
    lu.act_score_range_topics.each do |range|
      dup_range = ActScoreRangeTopic.new
      dup_range = range.dup
      self.act_score_range_topics << dup_range
    end
  end

  def duplicate_lu_folders(orig_lu)
    orig_lu.folders.each do |orig_folder|
      #  Identify or Create Folder
      new_folder = orig_folder.copy_to_org(self.classroom.organization)
      # copy over Folder Position For Topic
      orig_position = orig_folder.folder_positions.for_scope(orig_lu.id, orig_lu.class.to_s).first rescue nil
      new_position = FolderPosition.new
      new_position.scope_id = self.id
      new_position.scope_type = self.class.to_s
      new_position.position = orig_position.nil? ? 1 : orig_position.position
      new_position.is_hidden = orig_position.nil? ? false : orig_position.is_hidden
      new_folder.folder_positions << new_position
      # assign contents to topic folder
      orig_lu.topic_contents.for_folder(orig_folder).each do |tc|
        new_tc = TopicContent.new
        new_tc.folder_id = new_folder.id
        new_tc.position = tc.position
        new_tc.display_position = tc.display_position
        new_tc.content_id = tc.content_id
        self.topic_contents << new_tc
      end
    end
  end

end
