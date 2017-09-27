class Master::CaptchaController < Master::ApplicationController

    before_filter :set_captcha, only: [:destroy_captcha]

    def index
      @captchas = CaptchaImage.all
      @captcha = CaptchaImage.new
    end

    def create_captcha
      @captcha_image = CaptchaImage.new(params[:captcha_image])

      respond_to do |format|
        if @captcha_image.save
          format.html { redirect_to master_captcha_path, notice: "#{@captcha_image.name.upcase} has been created." }
          format.json { render :show, status: :ok, location: @captcha_image }
        else
          format.html { redirect_to master_captcha_path, notice: "#{@captcha_image.errors}" }
          format.json { render json: @captcha_image.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy_captcha
      @captcha_image.destroy
      respond_to do |format|
        format.html { redirect_to master_captcha_path, notice: 'Captcha Image has been deleted.' }
        format.json { head :no_content }
      end
    end

  private

    def set_captcha
      if params[:id]
        @captcha_image = CaptchaImage.find(params[:id])
      end
    end

    def captcha_params
      params.require(:captcha_image).permit(:name, :image)
    end
  end
