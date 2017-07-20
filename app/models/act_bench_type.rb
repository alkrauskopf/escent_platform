class ActBenchType < ActiveRecord::Base


  belongs_to :act_master

  has_many :act_benches, :dependent => :destroy

  scope :for_standard, lambda{|standard| {:conditions => ["act_master_id = ? ", standard.id]}}
  scope :for_resource_panel, :conditions => { :for_resource_panel => true }
  scope :for_dashboard, :conditions => { :for_dashbaord => true }
  scope :for_list, :conditions => { :for_list => true }
  scope :for_static, :conditions => { :for_statis => true }

  def self.improvement(std)
    where('act_master_id = ? && name = ?', std.id, 'suggestion' ).first rescue nil
  end
  def self.benchmark(std)
    where('act_master_id = ? && name = ?', std.id, 'benchmark' ).first rescue nil
  end
  def self.evidence(std)
    where('act_master_id = ? && name = ?', std.id, 'evidence' ).first rescue nil
  end
  def self.example(std)
    where('act_master_id = ? && name = ?', std.id, 'example' ).first rescue nil
  end
end
