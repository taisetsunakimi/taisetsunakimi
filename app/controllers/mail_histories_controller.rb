class MailHistoriesController < ApplicationController
  before_action :set_mail_history, only: [:show]
  def index
    @mail_histories = MailHistory.page(params[:page])
  end

  def show
  end

  private
    def set_mail_history
      @mail_history = MailHistory.find(params[:id])
    end
    def mail_history_params
      params.require(:mail_history).permit(:date, :notice_config, :mailaddr, :subject, :body, :bounce_info)
    end
end
