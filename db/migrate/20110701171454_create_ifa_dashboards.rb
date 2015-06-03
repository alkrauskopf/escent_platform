class CreateIfaDashboards < ActiveRecord::Migration
  def self.up
    create_table :ifa_dashboards do |t|
      t.integer :ifa_dashboardable_id
      t.string :ifa_dashboard_type
      t.integer :organization_id
      t.date :period_end
      t.integer :act_subject_id
      t.integer :assessments_taken
      t.integer :duration
      t.integer :answers_given
      t.integer :points_earned

      t.timestamps
    end
  end

  def self.down
    drop_table :ifa_dashboards
  end
end
