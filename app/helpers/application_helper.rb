module ApplicationHelper
  #メニュをアクティブにするために、現在のページを取得する
  def active?(controller_name)
     return "active" if controller_name == params[:controller]
  end
end
