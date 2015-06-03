class RenameMaxRecipients < ActiveRecord::Migration
  def self.up
   rename_column  :survey_instructions, :max_recipients, :max_returns
  end

  def self.down
   rename_column  :survey_instructions, :max_returns, :max_recipients
  end
end
