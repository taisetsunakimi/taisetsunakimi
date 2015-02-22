# coding: utf-8
class NoticeConfigsController < ApplicationController
  before_action :set_notice_config, only: [:show, :edit, :update]

  def index
    @notice_configs = NoticeConfig.all
  end

  def show
  end

  def edit
  end

  def update

    respond_to do |format|
      if @notice_config.update(notice_config_params)
        @hash = @notice_config
        chkbox = @hash["testmail"]
        if chkbox == "true"
           title = @hash["mail_subject"]
           body = @hash["mail_body"]
           NoticeMail.sendmail(title, body).deliver

           format.html { redirect_to @notice_config, notice: '更新し、テストメールを送りました。' }
           format.json { render :show, status: :ok, location: @notice_config }
        else
           format.html { redirect_to @notice_config, notice: '更新しました。' }
           format.json { render :show, status: :ok, location: @notice_config }
        end
      else
        format.html { render :edit }
        format.json { render json: @notice_config.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notice_config
      @notice_config = NoticeConfig.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notice_config_params
      params.require(:notice_config).permit(:medical_type, :notice_config, :mail_subject, :mail_body, :testmail)
    end
end
