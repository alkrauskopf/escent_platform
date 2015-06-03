class FolderFolderable < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :folderable, :polymorphic => true
  belongs_to :folder

  named_scope :for_class, lambda{|entity| {:conditions => ["folderable_type = ? ", entity.class.to_s]}}
end
