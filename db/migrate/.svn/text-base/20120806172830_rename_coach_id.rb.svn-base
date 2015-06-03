class RenameCoachId < ActiveRecord::Migration
  def self.up
     rename_column :dle_coach_assignments, :coach_id, :user_id
  end

  def self.down
     rename_column :dle_coach_assignments, :user_id, :coach_id
  end
end
