class CreateCaptchaImages < ActiveRecord::Migration
  def change
    create_table :captcha_images do |t|
      t.string :name

      t.timestamps
    end
    add_attachment :captcha_images, :image
  end
end
