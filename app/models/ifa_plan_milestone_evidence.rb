class IfaPlanMilestoneEvidence < ActiveRecord::Base
  attr_accessible :description, :ifa_plan_milestone_id, :name

  belongs_to :ifa_plan_milestone

  has_attached_file :evidence,
                    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                    :url => "/system/:attachment/:id/:style/:filename",
                    :styles => { :small_thumb => "50x50#" }
  validates_attachment :evidence,
                       content_type: {content_type: ['image/gif', 'image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png',
                                                     'application/pdf', 'application/x-pdf']}
  validates_with AttachmentSizeValidator, attributes: :evidence, less_than: 7.megabytes





end
