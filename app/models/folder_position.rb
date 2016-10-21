class FolderPosition < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :scope, :polymorphic => true
  belongs_to :folder

  scope :all, :order => "position"
  scope :org_scope, :conditions => ["scope_type = ?", "Organization"],  :order => "position"
  scope :lu_scope, :conditions => ["scope_type = ?", "Topic"],  :order => "position"
  scope :for_scope, lambda{|id, type| {:conditions => ["scope_id = ? AND scope_type = ?", id, type], :order=>'position'}}
  scope :for_folder, lambda{|folder| {:conditions => ["folder_id = ?", folder.id], :order=>'position'}}
  scope :hidden, :conditions => ["is_hidden = ?", true],  :order => "position"
  scope :visible, :conditions => ["is_hidden = ?", false],  :order => "position"

end
