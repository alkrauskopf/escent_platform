class AddAttachmentQuestionImageToActQuestions < ActiveRecord::Migration
  def self.up
    change_table :act_questions do |t|
      t.has_attached_file :question_image
    end
  end

  def self.down
    drop_attached_file :act_questions, :question_image
  end
end
