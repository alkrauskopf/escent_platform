class AddLogsAreClosedSurveyFields < ActiveRecord::Migration
  def self.up

    add_column :tlt_sessions, :logs_are_closed, :boolean
    add_column :tlt_dashboards, :involve_all, :integer
    add_column :tlt_dashboards, :involve_most, :integer
    add_column :tlt_dashboards, :involve_some, :integer
    add_column :tlt_dashboards, :involve_few, :integer

    execute "UPDATE tlt_sessions SET logs_are_closed = 1"
    execute "UPDATE tlt_dashboards SET involve_all = 0"
    execute "UPDATE tlt_dashboards SET involve_most = 0"
    execute "UPDATE tlt_dashboards SET involve_some = 0"
    execute "UPDATE tlt_dashboards SET involve_few = 0"
  end

  def self.down
    remove_column :tlt_sessions, :logs_are_closed
    remove_column :tlt_dashboards, :involve_all
    remove_column :tlt_dashboards, :involve_most
    remove_column :tlt_dashboards, :involve_some
    remove_column :tlt_dashboards, :involve_few

  end
end
