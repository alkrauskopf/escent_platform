class ChangeSmsHThresholdPrecision < ActiveRecord::Migration
  def self.up

    change_column :ifa_org_options, :sms_h_threshold, :decimal, :precision=>3, :scale => 2
  
  end

  def self.down

    change_column :ifa_org_options, :sms_h_threshold, :decimal
  
  end
end
