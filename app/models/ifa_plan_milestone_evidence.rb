class IfaPlanMilestoneEvidence < ActiveRecord::Base
  attr_accessible :explanation, :ifa_plan_milestone_id, :name, :documentation, :evidence

  belongs_to :ifa_plan_milestone

  has_attached_file :evidence,
                    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                    :url => "/system/:attachment/:id/:style/:filename",
                    :styles => { :small_thumb => "50x50#" }
  validates_attachment :evidence,
                       content_type: {content_type: ['image/gif', 'image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png',
                                                     'application/pdf', 'application/x-pdf']}
  validates_with AttachmentSizeValidator, attributes: :evidence, less_than: 7.megabytes

  validates_presence_of :name, :message => 'You Must Name Your Evidence '

  def milestone
    self.ifa_plan_milestone
  end

  def plan
    !self.milestone.nil? ? self.milestone.ifa_plan : nil
  end

  def student
    !self.plan.nil? ? self.plan.user : nil
  end

  def self.by_date
    order('updated_at DESC')
  end

  def image?
    self.attachment_type == 'Image'
  end

  def pdf?
    self.attachment_type == 'PDF'
  end

  def html?
    !self.documentation.nil? && !self.documentation.empty?
  end

  def attach_and_html?
    (self.image? || self.pdf?) && self.html?
  end

  def explanation?
    !self.explanation.nil? && !self.explanation.empty?
  end


  def content_type
    if self.evidence.present?
      if (self.evidence.content_type == 'image/gif') || (self.evidence.content_type == 'image/jpeg') || (self.evidence.content_type == 'image/png') || (self.evidence.content_type == 'image/pjpeg') || (self.evidence.content_type == 'image/x-png')
        content_type = 'Image'
      elsif (self.evidence.content_type == 'application/pdf') || (self.evidence.content_type == 'application/x-pdf')
        content_type = 'PDF'
      else
        content_type = 'Unkown'
      end
      if !self.documentation.nil? && !self.documentation.empty?
        content_type += ' and HTML'
      end
    elsif !self.documentation.nil? && !self.documentation.empty?
      content_type = 'HTML'
    else
      content_type = 'Empty'
    end
    content_type
  end

  def updateable?(user)
    !self.ifa_plan_milestone.nil? && !self.ifa_plan_milestone.achieved? && !self.ifa_plan_milestone.ifa_plan.nil? &&
        self.ifa_plan_milestone.ifa_plan.updateable?(user)
  end

  def attachment_type
    if self.evidence.present?
      if (self.evidence.content_type == 'image/gif') || (self.evidence.content_type == 'image/jpeg') || (self.evidence.content_type == 'image/png') || (self.evidence.content_type == 'image/pjpeg') || (self.evidence.content_type == 'image/x-png')
        attach_type = 'Image'
      elsif (self.evidence.content_type == 'application/pdf') || (self.evidence.content_type == 'application/x-pdf')
        attach_type = 'PDF'
      else
        attach_type = 'Unknown'
      end
    else
      attach_type = nil
    end
    attach_type
  end
end
