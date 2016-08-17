class GradeLevel < ActiveRecord::Base
 acts_as_list

 belongs_to :organization_type 
 has_many :elt_cases


  def self.secondary
   where('level <= ? AND level >= ?', 12, 9).order('level')
  end

 def self.middle
  where('level <= ? AND level >= ?', 8, 6).order('level')
 end

 def self.elementary
  where('level <= ?', 6).order('level')
 end

 def self.university
  where('level > ?', 12).order('level')
 end

 def self.pre_university
  where('level <= ?', 12).order('level')
 end
end
