# coding: utf-8
class NoticeConfigsController < ApplicationController
  before_action :set_notice_config, only: [:show, :edit, :update, :destroy]

  # GET /notice_configs
  # GET /notice_configs.json
  def index
    @notice_configs = NoticeConfig.all
  end

  # GET /notice_configs/1
  # GET /notice_configs/1.json
  def show
  end

  # GET /notice_configs/new
  def new
    @notice_config = NoticeConfig.new
  end

  # GET /notice_configs/1/edit
  def edit
  end

  # POST /notice_configs
  # POST /notice_configs.json

  def create
    @notice_config = NoticeConfig.new(notice_config_params)
    respond_to do |format|
      if @notice_config.save
        ### add - 
        hash = @notice_config
        chkbox = hash["testmail"]
        if chkbox == "true"
          title = hash["mail_subject"]
          body = hash["mail_body"] 
	  from = "root@taisetsunakimi.net"
          to = "guangchuan.h@gmail.com"
          ActionMailer::Base.mail(from: from, to: to, subject: title, body: body).deliver

          format.html { redirect_to @notice_config, notice: '作成し、テストメールを送りました。' }
          format.json { render :show, status: :created, location: @notice_config }
        else
          format.html { redirect_to @notice_config, notice: '作成しました。' }
          format.json { render :show, status: :created, location: @notice_config }
        end 
      else
        format.html { render :new }
        format.json { render json: @notice_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notice_configs/1
  # PATCH/PUT /notice_configs/1.json
  def update
    respond_to do |format|
      if @notice_config.update(notice_config_params)
        hash = @notice_config
        chkbox = hash["testmail"]
        if chkbox == "true"
           title = hash["mail_subject"]
           body = hash["mail_body"]
           from = "root@taisetsunakimi.net"
           to = "guangchuan.h@gmail.com"
           ActionMailer::Base.mail(from: from, to: to, subject: title, body: body).deliver
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

  # DELETE /notice_configs/1
  # DELETE /notice_configs/1.json
  def destroy
    @notice_config.destroy
    respond_to do |format|
      format.html { redirect_to notice_configs_url, notice: '削除しました。' }
      format.json { head :no_content }
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
