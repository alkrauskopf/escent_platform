class RenameYearMonthCol < ActiveRecord::Migration
  def self.up

    rename_column  :itl_summaries, :year_month, :yr_mnth


  end

  def self.down

    rename_column  :itl_summaries, :yr_mnth, :year_month

  end
end
