class EltCaseEvidence < ActiveRecord::Base

  include PublicPersona

  belongs_to :elt_case
  belongs_to :user

  has_attached_file :elt_evidence,
                    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                    :url => "/system/:attachment/:id/:style/:filename",
                    :styles => { :thumb => "118x166#", :med_thumb => "80x112#", :small_thumb => "50x50#" }
  validates_attachment :elt_evidence,
                       content_type: {content_type: ['image/gif', 'image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png']}
  validates_with AttachmentSizeValidator, attributes: :elt_evidence, less_than: 5.megabytes

  validates_presence_of :description, :message => "(Need A Description)"

  belongs_to :elt_case
  belongs_to :user

  def submitter_name
    self.user ? self.user.last_name : 'Unknown Submitter'
  end


end
