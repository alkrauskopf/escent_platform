class AddDocumentationToEvidence < ActiveRecord::Migration
  def change
    rename_column :ifa_plan_milestone_evidences, :description, :explanation
    add_column :ifa_plan_milestone_evidences, :documentation, :text
  end
end
