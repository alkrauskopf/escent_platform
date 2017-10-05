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
  has_many :folder_mastery_levels, :dependent => :destroy
  has_many :act_score_ranges, :through => :folder_mastery_levels


  scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id], :order=>'name'}}
  scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id], :order=>'name'}}
  scope :all_parents,   :conditions => ["parent_id IS NULL"], :order=>'name'
 # scope :by_position,   :include  => [:folder_positions], :order=>'folder_position.position'
  
  validates_presence_of :name


  def standards_tagged?
    !self.folder_mastery_levels.empty?
  end

  def mastery_levels
    self.standards_tagged? ?  self.act_score_ranges.sort_by{|sr| [sr.act_master.abbrev,sr.act_subject.name, sr.lower_score]} : []
  end

  def self.with_mastery(mastery)
    where('folder_mastery_levels.act_score_range_id = ?', mastery.id).includes(:folder_mastery_levels)
  end

  def mastery_string
    string = ''
    if self.standards_tagged?
      string = self.mastery_levels.collect{|l| (l.range)}.join(', ')
    end
    string
  end

  def subject_mastery_levels(subject)
    self.act_score_ranges.for_subject(subject).sort_by{|sr| [sr.act_master.abbrev,sr.act_subject.name, sr.lower_score]}
  end

  def self.by_position(folders)
   unless folders.empty?
     folders.sort_by{|f| f.folder_positions.first.pos}
   else
     []
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

  def show?(lu)
    !self.hidden?(lu.id, lu.class.to_s)
  end

  def teacher_only?(lu)
    self.for_teacher?(lu.id, lu.class.to_s)
  end

  def for_teacher?(scope_id, scope_type)
    self.position_for_scope(scope_id, scope_type).nil? ? false : self.position_for_scope(scope_id, scope_type).for_teacher
  end

  def hide?(lu)
    self.hidden?(lu.id, lu.class.to_s)
  end

  def no_lu_contents?(lu)
    self.topic_contents.for_lu(lu).empty?
  end

  def classrooms
      FolderFolderable.where('folderable_type = ? AND folder_id = ?', 'Classroom', self.id,).collect{|ff| ff.folderable}.flatten.compact.uniq
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

  def hidden?(scope_id, scope_type)
    self.position_for_scope(scope_id, scope_type).nil? ? false : self.position_for_scope(scope_id, scope_type).is_hidden
  end

  def copy_to_org(org)
    new_folder = org.folders.where('name = ?', self.name).first rescue nil
    if new_folder.nil?
      new_folder = Folder.new
      new_folder = self.dup
      new_folder.parent_id = nil
      org.folders << new_folder
      # copy Mastery Levels to new folder
      self.folder_mastery_levels.each do |ml|
        new_ml = FolderMasteryLevel.new
        new_ml.act_score_range_id = ml.act_score_range_id
        new_folder.folder_mastery_levels << new_ml
      end
    end
    new_folder
  end
end
