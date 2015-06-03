class IndexToTltSessions < ActiveRecord::Migration
  def self.up
    add_index :tlt_sessions, [:organization_id, :subject_area_id, :session_date], :name => "org_subject_date"
    add_index :tlt_sessions, [:user_id, :subject_area_id, :session_date], :name => "teacher_subject_date"
    add_index :tlt_sessions, [:organization_id, :session_date], :name => "org_session_date"
    add_index :tlt_sessions, [:organization_id, :tracker_id, :session_date], :name => "org_observer_date"
    add_index :tlt_sessions, [:organization_id, :user_id, :session_date], :name => "org_teacher_date"
    add_index :tlt_sessions, [:user_id, :session_date], :name => "teacher_date"
  end

  def self.down
    remove_index :tlt_sessions, [:organization_id, :subject_area_id, :session_date], :name => "org_subject_date"
    remove_index :tlt_sessions, [:user_id, :subject_area_id, :session_date], :name => "teacher_subject_date"
    remove_index :tlt_sessions, [:organization_id, :session_date], :name => "org_session_date"
    remove_index :tlt_sessions, [:organization_id, :tracker_id, :session_date], :name => "org_observer_date"
    remove_index :tlt_sessions, [:organization_id, :user_id, :session_date], :name => "org_teacher_date"
    remove_index :tlt_sessions, [:user_id, :session_date], :name => "teacher_date"
  end
end
