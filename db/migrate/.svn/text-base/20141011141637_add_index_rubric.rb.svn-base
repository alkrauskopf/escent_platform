class AddIndexRubric < ActiveRecord::Migration
  def self.up
    add_index :rubrics, [:scope_id, :scope]
    add_index :rubrics, [:scope, :scope_id]
  end

  def self.down
    remove_index :rubrics, [:scope_id, :scope]
    remove_index :rubrics, [:scope, :scope_id]
  end
end
