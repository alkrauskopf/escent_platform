class RenameMaxResponses < ActiveRecord::Migration
  def self.up
   rename_column  :survey_instructions, :max_returns, :max_responses
  end

  def self.down
   rename_column  :survey_instructions, :max_responses, :max_returns
  end

end
