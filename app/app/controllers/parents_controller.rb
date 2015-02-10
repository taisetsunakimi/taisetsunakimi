class ParentsController < ApplicationController
  def new
    @parent = Parent.new(mailaddr: cookies[:mailaddr], apple_no: cookies[:apple_no], tel_no: cookies[:tel_no], 
                         birthday: cookies[:birthday],fetus_week: cookies[:fetus_week],
                         fetus_day: cookies[:fetus_day],birthweight: cookies[:birthweight])
  end
  def create
    @parent = Parent.new(parent_params)
    if @parent.save
      p 'save できたよ'
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
      flash[:success] = "お知らせ機能に登録しました！"
      redirect_to :action => 'new'

    else

      p 'save できなかったよ'
      p @parent.errors.full_messages
      render 'new'
    end  
  end
  def question
   
  end

  private

    def parent_params
      params.require(:parent).permit(:mailaddr, :apple_no, :tel_no, :birthday,
                                     :fetus_week, :fetus_day, :birthweight, :remember_input)
    end

end
