class Folder < ActiveRecord::Base
  include PublicPersona
  
  acts_as_tree
  
  belongs_to :coop_app
  belongs_to :organization

  has_one   :total_view, :as => :entity, :dependent => :destroy

  has_many :topic_contents, :dependent => :destroy
  has_many :contents, :through => :topic_contents
  has_many :lu_resources, :through => :topic_contents, :source=>:content, :uniq=>true
  has_many :topics, :through => :topic_contents
  has_many :folder_folderables, :dependent => :destroy
  has_many :folder_positions, :dependent => :destroy
  
  scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id], :order=>'name'}}
  scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id], :order=>'name'}}
  scope :all_parents,   :conditions => ["parent_id IS NULL"], :order=>'name'
#  scope :by_position,   :include  => [:folder_positions], :order=>'folder_positions.position'
  
  validates_presence_of :name

  
  def self.by_position
   self.sort_by{|f| f.folder_positions.position}
  end

  def increment_views
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.increment
  end
  
  def views
    self.total_view ||= TotalView.create(:entity => self)
    self.total_view.views
  end
  
  def child?
    !self.parent_id.nil?
  end
  
  def parent?
    self.parent_id.nil?
  end

  def parent_folder
    self.parent? ? self : (self.parent ? self.parent : self)
  end

  def parent_child_names
    self.parent? ? self.name : (self.parent ? (self.parent.name + ": " + self.name) : (" " + self.name))
  end
  
  def all_children
    (self.children + self.children.collect{|child| child.children}).flatten
  end  

  def resources_for_lu(lu)
    self.topic_contents.for_lu(lu).sort_by{|tc| tc.position}.collect{|tc| tc.content}.compact.select{|c| c.active?}
  end

  def no_lu_contents?(lu)
    self.topic_contents.for_lu(lu).empty?
  end

  def classrooms
      FolderFolderable.all.where('folderable_type = ? AND folder_id = ?', 'Classroom', self.id,).collect{|ff| ff.folderable}.flatten.compact.uniq
  end

  def includes_entity?(entity)
    entity.folder ? (entity.folder == self) : false
  end

  def class_contents(entity)
    self.folder_folderables.for_class(entity)
  end

  def empty_of_class?(entity)
    self.folder_folderables.for_class(entity).empty?
  end

  def position_for_scope(scope_id, scope_type)
    self.folder_positions.for_scope(scope_id, scope_type).first ? self.folder_positions.for_scope(scope_id, scope_type).first: nil
  end

  def position(scope_id, scope_type)
    self.position_for_scope(scope_id, scope_type).nil? ? 0 : self.position_for_scope(scope_id, scope_type).position
  end

end
