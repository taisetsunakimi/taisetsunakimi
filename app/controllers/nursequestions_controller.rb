class NursequestionsController < ApplicationController
  def new
    @question = Nursequestion.new(mailaddr: cookies[:n_mailaddr], belong: cookies[:n_belong],
                                  tel_no: cookies[:n_tel_no], name: cookies[:n_name])

  end
  def create
    @question = Nursequestion.new(question_params)
    p @question
    if @question.save
      p 'question save できたよ'
      # 保存の成功をここで扱う。
      if @question.remember_input
        cookies.permanent[:n_mailaddr] = { :value => @question.mailaddr, :http_only => true}
        cookies.permanent[:n_belong] = { :value => @question.belong, :http_only => true}
        cookies.permanent[:n_tel_no] = { :value => @question.tel_no, :http_only => true}
        cookies.permanent[:n_name] = { :value => @question.name, :http_only => true}
      else
        cookies.delete :n_mailaddr
        cookies.delete :n_tel_no
        cookies.delete :n_belong
        cookies.delete :n_name
      end

      flash[:success] = "質問を登録しました！"
      redirect_to :controller => "nursequestions", :action => "new"
    else
      p 'question save できなかったよ'
      p @question.errors.full_messages
      render :template => "nursequestions/new"
    end
  end

  private
    def question_params
      params.require(:nursequestion).permit(:mailaddr, :belong, :tel_no, :name, :question_txt, :remember_input)
    end
end
