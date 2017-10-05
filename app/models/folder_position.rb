class FolderPosition < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :scope, :polymorphic => true
  belongs_to :folder

  scope :all, :order => "pos"
  scope :org_scope, :conditions => ["scope_type = ?", "Organization"],  :order => "pos"
  scope :lu_scope, :conditions => ["scope_type = ?", "Topic"],  :order => "pos"
  scope :for_scope, lambda{|id, type| {:conditions => ["scope_id = ? AND scope_type = ?", id, type], :order=>'pos'}}
  scope :for_folder, lambda{|folder| {:conditions => ["folder_id = ?", folder.id], :order=>'pos'}}
  scope :hidden, :conditions => ["is_hidden = ?", true],  :order => "pos"
  scope :visible, :conditions => ["is_hidden = ?", false],  :order => "pos"
  scope :teacher_only, :conditions => ["for_teacher = ?", true],  :order => "pos"
  scope :for_all, :conditions => ["for_teacher = ?", false],  :order => "pos"

end
