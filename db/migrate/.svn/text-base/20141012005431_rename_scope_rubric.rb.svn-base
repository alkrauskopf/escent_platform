class RenameScopeRubric < ActiveRecord::Migration
  def self.up
   rename_column  :rubrics, :scope, :scope_type
  end

  def self.down
   rename_column  :rubrics, :scope_type, :scope
  end
end
