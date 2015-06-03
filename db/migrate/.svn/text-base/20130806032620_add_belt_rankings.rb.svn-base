class AddBeltRankings < ActiveRecord::Migration
  def self.up

  add_column  :tlt_sessions, :itl_belt_rank_id, :integer
  add_column  :itl_org_options, :is_belt_ranking, :boolean

  execute "UPDATE itl_org_options SET is_belt_ranking = 0"
  add_index :tlt_sessions, :itl_belt_rank_id
    
  end

  def self.down

  remove_index :tlt_sessions, :itl_belt_rank_id

  remove_column  :tlt_sessions, :itl_belt_rank_id
  remove_column  :itl_org_options, :is_belt_ranking

  end
end
