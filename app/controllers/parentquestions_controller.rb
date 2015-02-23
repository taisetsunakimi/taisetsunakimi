class ParentquestionsController < ApplicationController
  def create
    # upsert(レコードがないときはinsert、ある時はupdate）できるように
    # ビジネスキーでfind_or_initialize_byする
    if parent_params[:birthday] == ""
      tmp_birthday = Date.today
    else
      tmp_birthday = parent_params[:birthday]
    end

    @parent = Parent.find_or_initialize_by(:mailaddr => parent_params[:mailaddr], :birthday => tmp_birthday)
    @parent.apple_no = parent_params[:apple_no]
    @parent.tel_no = parent_params[:tel_no]
    @parent.fetus_week = parent_params[:fetus_week]
    @parent.fetus_day = parent_params[:fetus_day]
    @parent.birthweight = parent_params[:birthweight]
    @parent.remember_input = parent_params[:remember_input]
    @question = Parentquestion.new(:question_txt => question_params[:question_txt], :register_reminder => question_params[:register_reminder])
    @question.parent = @parent
    @parent.notice_flg = @question.register_reminder
    
    if @parent.save
      p 'parent save できたよ'
      p @parent
      p @question
      if @question.save
        p 'question save できたよ'
        # メール送信
        ParentsMailer.parentsmail(@parent, @question).deliver

        # 保存の成功をここで扱う。
        if @parent.remember_input
          cookies.permanent[:mailaddr] = { :value => @parent.mailaddr, :http_only => true}
          cookies.permanent[:apple_no] = { :value => @parent.apple_no, :http_only => true}
          cookies.permanent[:tel_no] = { :value => @parent.tel_no, :http_only => true}
          cookies.permanent[:birthday] = { :value => @parent.birthday, :http_only => true}
          cookies.permanent[:fetus_week] = { :value => @parent.fetus_week, :http_only => true}
          cookies.permanent[:fetus_day] = { :value => @parent.fetus_day, :http_only => true}
          cookies.permanent[:birthweight] = { :value => @parent.birthweight, :http_only => true}
        else
          cookies.delete :mailaddr
          cookies.delete :apple_no
          cookies.delete :tel_no
          cookies.delete :birthday
          cookies.delete :fetus_week
          cookies.delete :fetus_day
          cookies.delete :birthweight
        end

        flash[:success] = "質問を登録しました！"
        redirect_to :controller => "parents", :action => "new"

      else
        p 'question save できなかったよ'
        p @question.errors.full_messages
        render :template => "parents/new"
      end
    else
        p 'parent save できなかったよ'
        p @parent.errors.full_messages
        @question.errors.full_messages.push @parent.errors.full_messages
        render :template => "parents/new"
    end  
  end

  private
    def parent_params
      params.require(:parentquestion).permit(:mailaddr, :apple_no, :tel_no, :birthday,
                                     :fetus_week, :fetus_day, :birthweight, :remember_input)
    end

    def question_params
      params.require(:parentquestion).permit(:register_reminder, :question_txt)
    end
end
