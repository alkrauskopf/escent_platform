class RemoveCycleSummaryColumns < ActiveRecord::Migration
  def self.up
    remove_column  :elt_cycle_summaries, :cycle
    remove_column  :elt_cycle_summaries, :activity
    remove_column  :elt_cycle_summaries, :indicator
    remove_column  :elt_cycle_summaries, :element
  end

  def self.down
    add_column  :elt_cycle_summaries, :element, :string
    add_column  :elt_cycle_summaries, :activity, :string
    add_column  :elt_cycle_summaries, :indicator, :string
    add_column  :elt_cycle_summaries, :cycle, :string
  end
end
