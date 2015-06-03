class ReplaceCycleSummaryRating < ActiveRecord::Migration
  def self.up
    remove_column  :elt_cycle_summaries, :rating
    remove_column  :elt_cycle_summaries, :school_count
    add_column  :elt_cycle_summaries, :score_count, :integer, :default => 0
    add_column  :elt_cycle_summaries, :score_total, :integer, :default => 0
  end

  def self.down
    add_column  :elt_cycle_summaries, :school_count, :integer, :default => 0
    add_column  :elt_cycle_summaries, :rating, :decimal, :precision => 6, :scale => 3, :default => 0.0   
    remove_column  :elt_cycle_summaries, :score_count
    remove_column  :elt_cycle_summaries, :score_total
  end
end
