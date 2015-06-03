class CreateTltDashboards < ActiveRecord::Migration
  def self.up
    create_table :tlt_dashboards do |t|
      t.integer :tlt_session_id
      t.integer :user_id
      t.integer :tracker_id
      t.integer :classroom_id
      t.integer :topic_id
      t.integer :organization_id
      t.integer :tl_activity_type_id
      t.integer :tl_activity_type_task_id
      t.integer :subject_area_id
      t.integer :duration_secs
      t.integer :durattion_pct
      t.integer :segments

      t.timestamps
    end
    add_index :tlt_dashboards, :tlt_session_id
    add_index :tlt_dashboards, :user_id
    add_index :tlt_dashboards, :tracker_id
    add_index :tlt_dashboards, :classroom_id
    add_index :tlt_dashboards, :topic_id
    add_index :tlt_dashboards, :organization_id
    add_index :tlt_dashboards, :tl_activity_type_id
    add_index :tlt_dashboards, :tl_activity_type_task_id
    add_index :tlt_dashboards, :subject_area_id
  end

  def self.down
    drop_table :tlt_dashboards
  end
end
