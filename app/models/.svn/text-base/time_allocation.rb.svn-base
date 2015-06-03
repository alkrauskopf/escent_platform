class TimeAllocation < ActiveRecord::Base
  include PublicPersona

  belongs_to :organization

  validates_numericality_of :weekday_std, :greater_than_or_equal_to => 0.0, :message => 'must >= 0.0  '
  validates_numericality_of :hrsday_std, :greater_than_or_equal_to => 0.0, :message => 'must >= 0.0  '
  validates_numericality_of :daysyear_std, :greater_than_or_equal_to => 0.0, :message => 'must >= 0.0  '
  validates_numericality_of :hrsday_er, :greater_than_or_equal_to => 0.0, :message => 'must >= 0.0  '
  validates_numericality_of :daysyear_er, :greater_than_or_equal_to => 0.0, :message => 'must >= 0.0  '
  validates_numericality_of :hrsday_ls, :greater_than_or_equal_to => 0.0, :message => 'must >= 0.0  '
  validates_numericality_of :daysyear_ls, :greater_than_or_equal_to => 0.0, :message => 'must >= 0.0  '
  validates_numericality_of :fte_teacher, :greater_than_or_equal_to => 0.0, :message => 'must >= 0.0  '
  validates_numericality_of :fte_admin, :greater_than_or_equal_to => 0.0, :message => 'must >= 0.0  '
  validates_numericality_of :total_students, :greater_than_or_equal_to => 0, :message => 'must >= 0  '

end
