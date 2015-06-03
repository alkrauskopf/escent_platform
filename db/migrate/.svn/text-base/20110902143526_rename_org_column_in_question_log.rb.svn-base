class RenameOrgColumnInQuestionLog < ActiveRecord::Migration
  def self.up

  rename_column :ifa_question_logs, :organziation_id, :organization_id
  
  end

  def self.down

  rename_column :ifa_question_logs, :organization_id, :organziation_id
  
  end
end
