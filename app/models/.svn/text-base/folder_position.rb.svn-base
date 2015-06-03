class FolderPosition < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :scope, :polymorphic => true
  belongs_to :folder

  named_scope :all, :order => "position"
  named_scope :org_scope, :conditions => ["scope_type = ?", "Organization"],  :order => "position"
  named_scope :lu_scope, :conditions => ["scope_type = ?", "Topic"],  :order => "position"
  named_scope :for_scope, lambda{|id, type| {:conditions => ["scope_id = ? AND scope_type = ?", id, type], :order=>'position'}}
  named_scope :for_folder, lambda{|folder| {:conditions => ["folder_id = ?", folder.id], :order=>'position'}}



end
