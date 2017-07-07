class AddAttachmentEvidenceToIfaPlanMilestoneEvidences < ActiveRecord::Migration
  def self.up
    change_table :ifa_plan_milestone_evidences do |t|
      t.has_attached_file :evidence
    end
  end

  def self.down
    drop_attached_file :ifa_plan_milestone_evidences, :evidence
  end
end
